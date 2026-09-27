import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/runtime/runtime_vm_log.dart';
import 'package:test/test.dart';

void main() {
  const vmLine =
      'I/flutter ( 5101): The Dart VM service is listening on '
      'http://127.0.0.1:32973/R9dHW1ehmAQ=/';

  test('parses the debug VM service URI from a logcat line', () {
    final uri = dartVmServiceHttpUri(vmLine);

    expect(uri, isNotNull);
    expect(uri!.host, '127.0.0.1');
    expect(uri.port, 32973);
    expect(uri.path, '/R9dHW1ehmAQ=/');
    expect(
      dartVmServiceWebSocketUri(uri),
      'ws://127.0.0.1:32973/R9dHW1ehmAQ=/ws',
    );
    expect(dartVmServiceHttpUri('I/flutter ( 1): hello'), isNull);
  });

  test('adds /ws when the observatory path has no trailing slash', () {
    final uri = dartVmServiceHttpUri(
      'The Dart VM service is listening on http://127.0.0.1:9/token.',
    );

    expect(uri!.path, '/token');
    expect(dartVmServiceWebSocketUri(uri), 'ws://127.0.0.1:9/token/ws');
  });

  test('drops only the viewport-metrics flood', () {
    expect(
      isViewportMetricsNoise(
        'D/FlutterJNI( 5101): Sending viewport metrics to the engine.',
      ),
      isTrue,
    );
    expect(
      isViewportMetricsNoise(
        'D/FlutterJNI( 5101): Beginning load of flutter...',
      ),
      isFalse,
    );
  });

  test('formats a developer log the way flutter run prints it', () {
    expect(
      formatDartDeveloperLog(
        loggerName: 'GoRouter',
        message: 'going to /profile',
      ),
      '[GoRouter] going to /profile',
    );
    expect(
      formatDartDeveloperLog(
        loggerName: 'SessionManager',
        message: '[ERROR] Refresh failed',
        error: 'Exception: Token refresh failure',
        stackTrace: '#0 SessionManager.refreshTokens',
      ),
      '[SessionManager] [ERROR] Refresh failed\n'
      'Exception: Token refresh failure\n'
      '#0 SessionManager.refreshTokens',
    );
  });

  test('redacts the VM service URI from a connect failure', () {
    final uri = dartVmServiceHttpUri(vmLine)!;
    final text = redactVmServiceUri(
      'WebSocketException: ${dartVmServiceWebSocketUri(uri)} refused',
      uri,
    );

    expect(text, contains('<vm-service>'));
    expect(text, isNot(contains('R9dHW1ehmAQ')));
  });

  test('writes VM logs, drops viewport noise, and follows a new URI', () async {
    final stdout = StreamController<List<int>>();
    final stderr = StreamController<List<int>>();
    var stopped = false;
    var removedForwards = 0;
    final connections = <_FakeVmLog>[];
    final attacher = FlutterRuntimeLogcatAttacher(
      startFlutterLogs: (device) async {
        expect(device, 'emulator-5554');
        return FlutterLogsSession(
          stdout: stdout.stream,
          stderr: stderr.stream,
          stop: () => stopped = true,
        );
      },
      forwardPort: (device, port) async {
        expect(device, 'emulator-5554');
        return VmPortForward(
          hostPort: port == 32973 ? 1111 : 2222,
          remove: () async => removedForwards++,
        );
      },
      connectVmLog: (uri) async {
        final connection = _FakeVmLog(uri);
        connections.add(connection);
        return connection;
      },
    );
    final root = await Directory.systemTemp.createTemp('runtime_vm_log_');
    addTearDown(() async {
      await attacher.stop();
      await root.delete(recursive: true);
    });
    final log = File('${root.path}/logcat.log');

    await attacher.start(device: 'emulator-5554', logFile: log);
    stdout.add(utf8.encode('Showing sdk gphone64 x86 64 logs:\n'));
    stdout.add(
      utf8.encode(
        'D/FlutterJNI( 5101): Sending viewport metrics to the engine.\n',
      ),
    );
    stdout.add(utf8.encode('$vmLine\n'));
    stderr.add(utf8.encode('D/FlutterJNI( 1): Beginning load of flutter...\n'));
    await _until(() => connections.length == 1);

    connections.single.add('[GoRouter] going to /profile');
    await _until(
      () => log.readAsStringSync().contains('[GoRouter] going to /profile'),
    );

    const next =
        'I/flutter ( 2): The Dart VM service is listening on '
        'http://127.0.0.1:40000/nextToken=/';
    stdout.add(utf8.encode('$next\n'));
    await _until(() => connections.length == 2);
    expect(connections.first.uri.port, 1111);
    expect(connections.last.uri.port, 2222);
    expect(connections.first.closed, isTrue);
    expect(removedForwards, 1);
    connections.last.add('[SessionManager] [DEBUG] Session init');
    await _until(
      () => log.readAsStringSync().contains('[SessionManager] [DEBUG]'),
    );

    await attacher.stop();
    await stdout.close();
    await stderr.close();
    expect(stopped, isTrue);
    expect(removedForwards, 2);
    final text = log.readAsStringSync();
    expect(text, contains('Showing sdk gphone64 x86 64 logs:'));
    expect(text, contains('Beginning load of flutter...'));
    expect(text, contains('http://127.0.0.1:32973/R9dHW1ehmAQ=/'));
    expect(text, isNot(contains('viewport metrics')));
    expect(text, contains('[GoRouter] going to /profile'));
    expect(text, contains('[SessionManager] [DEBUG] Session init'));
  });

  test('records a subscribe failure without the VM token', () async {
    final stdout = StreamController<List<int>>();
    final attacher = FlutterRuntimeLogcatAttacher(
      startFlutterLogs: (_) async => FlutterLogsSession(
        stdout: stdout.stream,
        stderr: const Stream<List<int>>.empty(),
        stop: () {},
      ),
      forwardPort: (device, port) async =>
          VmPortForward(hostPort: port, remove: () async {}),
      connectVmLog: (uri) async {
        throw Exception('refused ${dartVmServiceWebSocketUri(uri)}');
      },
    );
    final root = await Directory.systemTemp.createTemp('runtime_vm_log_fail_');
    addTearDown(() async {
      await attacher.stop();
      await root.delete(recursive: true);
    });
    final log = File('${root.path}/logcat.log');

    await attacher.start(device: 'emulator-5554', logFile: log);
    stdout.add(utf8.encode('$vmLine\n'));
    await _until(
      () => log.readAsStringSync().contains('VM log subscribe failed'),
    );

    final failure = log.readAsLinesSync().singleWhere(
      (line) => line.contains('VM log subscribe failed'),
    );
    expect(failure, contains('[mobilekit] VM log subscribe failed:'));
    expect(failure, contains('<vm-service>'));
    expect(failure, isNot(contains('R9dHW1ehmAQ')));
    await stdout.close();
  });
}

class _FakeVmLog implements VmLogConnection {
  _FakeVmLog(this.uri);

  final Uri uri;
  final StreamController<String> _lines = StreamController<String>();
  var closed = false;

  @override
  Stream<String> get lines => _lines.stream;

  void add(String line) => _lines.add(line);

  @override
  Future<void> close() async {
    closed = true;
    await _lines.close();
  }
}

Future<void> _until(bool Function() ready) async {
  for (var attempt = 0; attempt < 50 && !ready(); attempt++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(ready(), isTrue);
}
