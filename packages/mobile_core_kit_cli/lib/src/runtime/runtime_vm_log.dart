import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

/// Best-effort device log capture for a Maestro evidence run.
abstract class RuntimeLogcatAttacher {
  Future<void> start({required String device, required File logFile});

  Future<void> stop();
}

final _vmServiceUri = RegExp(
  r'The Dart VM service is listening on (https?://\S+)',
);

/// HTTP observatory URI printed by a debug Flutter process, if [line]
/// contains one.
Uri? dartVmServiceHttpUri(String line) {
  final match = _vmServiceUri.firstMatch(line);
  if (match == null) return null;
  var raw = match.group(1)!;
  while (raw.endsWith('.') || raw.endsWith(',')) {
    raw = raw.substring(0, raw.length - 1);
  }
  final uri = Uri.tryParse(raw);
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
  return uri;
}

/// WebSocket endpoint for [httpUri], as used by `flutter run`.
String dartVmServiceWebSocketUri(Uri httpUri) {
  final scheme = httpUri.scheme == 'https' ? 'wss' : 'ws';
  var path = httpUri.path;
  if (!path.endsWith('/')) path = '$path/';
  return httpUri.replace(scheme: scheme, path: '${path}ws').toString();
}

/// Engine line that repeats for every frame and crowds out the app log.
bool isViewportMetricsNoise(String line) {
  return line.contains('Sending viewport metrics to the engine.');
}

/// One `dart:developer` `log()` record, in the form `flutter run` prints.
String formatDartDeveloperLog({
  required String? loggerName,
  required String message,
  String? error,
  String? stackTrace,
}) {
  final name = (loggerName == null || loggerName.isEmpty) ? 'log' : loggerName;
  final buffer = StringBuffer('[$name] $message');
  if (error != null && error.isNotEmpty) {
    buffer
      ..writeln()
      ..write(error);
  }
  if (stackTrace != null && stackTrace.isNotEmpty) {
    buffer
      ..writeln()
      ..write(stackTrace);
  }
  return buffer.toString();
}

/// Removes the VM service URI from [text] so a connect failure can be logged.
String redactVmServiceUri(String text, Uri httpUri) {
  final ws = dartVmServiceWebSocketUri(httpUri);
  final token = httpUri.pathSegments.where((part) => part.isNotEmpty).join('/');
  var redacted = text
      .replaceAll(httpUri.toString(), '<vm-service>')
      .replaceAll(ws, '<vm-service>');
  if (token.isNotEmpty) redacted = redacted.replaceAll(token, '<token>');
  return redacted;
}

/// Host side of an `adb forward` for the device VM service port.
class VmPortForward {
  const VmPortForward({required this.hostPort, required this.remove});

  final int hostPort;
  final Future<void> Function() remove;
}

typedef VmPortForwarder =
    Future<VmPortForward> Function(String device, int devicePort);

/// Live `flutter logs` streams plus a way to stop the process.
class FlutterLogsSession {
  const FlutterLogsSession({
    required this.stdout,
    required this.stderr,
    required this.stop,
  });

  final Stream<List<int>> stdout;
  final Stream<List<int>> stderr;
  final void Function() stop;
}

/// Subscription to the Dart VM Logging stream.
abstract interface class VmLogConnection {
  Stream<String> get lines;

  Future<void> close();
}

class _DartVmLogConnection implements VmLogConnection {
  _DartVmLogConnection({
    required this.lines,
    required Future<void> Function() close,
  }) : _close = close;

  @override
  final Stream<String> lines;

  final Future<void> Function() _close;

  @override
  Future<void> close() => _close();
}

typedef FlutterLogsStarter = Future<FlutterLogsSession> Function(String device);

typedef VmLogConnector = Future<VmLogConnection> Function(Uri httpUri);

/// Attaches `flutter logs` and the Dart VM Logging stream into one file.
class FlutterRuntimeLogcatAttacher implements RuntimeLogcatAttacher {
  FlutterRuntimeLogcatAttacher({
    FlutterLogsStarter? startFlutterLogs,
    VmLogConnector? connectVmLog,
    VmPortForwarder? forwardPort,
  }) : _startFlutterLogs = startFlutterLogs ?? _startFlutterLogsProcess,
       _connectVmLog = connectVmLog ?? connectDartVmServiceLog,
       _forwardPort = forwardPort ?? forwardAdbVmServicePort;

  final FlutterLogsStarter _startFlutterLogs;
  final VmLogConnector _connectVmLog;
  final VmPortForwarder _forwardPort;

  String? _device;
  FlutterLogsSession? _session;
  RandomAccessFile? _file;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  StreamSubscription<String>? _vmSub;
  VmLogConnection? _vm;
  VmPortForward? _portForward;
  Future<void> _vmChain = Future<void>.value();
  String? _connectedUri;
  var _stopped = false;

  @override
  Future<void> start({required String device, required File logFile}) async {
    _stopped = false;
    _device = device;
    logFile.parent.createSync(recursive: true);
    if (!logFile.existsSync()) {
      logFile.createSync();
    }
    _file = logFile.openSync(mode: FileMode.append);
    final session = await _startFlutterLogs(device);
    _session = session;
    _stdoutSub = _lines(session.stdout).listen(_onLogcatLine, onError: (_) {});
    _stderrSub = _lines(session.stderr).listen(_onLogcatLine, onError: (_) {});
  }

  @override
  Future<void> stop() async {
    _stopped = true;
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _session?.stop();
    _session = null;
    await _vmChain;
    await _closeVm();
    final file = _file;
    _file = null;
    await file?.close();
  }

  Stream<String> _lines(Stream<List<int>> bytes) {
    return bytes.transform(utf8.decoder).transform(const LineSplitter());
  }

  void _onLogcatLine(String line) {
    final uri = dartVmServiceHttpUri(line);
    if (uri != null) _subscribe(uri);
    if (isViewportMetricsNoise(line)) return;
    _write(line);
  }

  void _subscribe(Uri uri) {
    final key = uri.toString();
    if (_stopped || key == _connectedUri) return;
    _connectedUri = key;
    _vmChain = _vmChain.then((_) async {
      if (_stopped || _connectedUri != key) return;
      await _closeVm();
      try {
        final device = _device;
        if (device == null) return;
        final forwarded = await _forwardPort(device, uri.port);
        if (_stopped || _connectedUri != key) {
          await forwarded.remove();
          return;
        }
        _portForward = forwarded;
        final connection = await _connectVmLog(
          uri.replace(port: forwarded.hostPort),
        );
        if (_stopped || _connectedUri != key) {
          await connection.close();
          await _closeVm();
          return;
        }
        _vm = connection;
        _vmSub = connection.lines.listen(_write, onError: (_) {});
      } catch (error) {
        await _closeVm();
        _write(
          '[mobilekit] VM log subscribe failed: '
          '${redactVmServiceUri(error.toString(), uri)}',
        );
      }
    });
  }

  Future<void> _closeVm() async {
    await _vmSub?.cancel();
    _vmSub = null;
    final connection = _vm;
    _vm = null;
    if (connection != null) await connection.close();
    final forwarded = _portForward;
    _portForward = null;
    if (forwarded != null) await forwarded.remove();
  }

  void _write(String line) {
    if (_stopped) return;
    _file?.writeStringSync('$line\n');
  }
}

Future<VmPortForward> forwardAdbVmServicePort(
  String device,
  int devicePort,
) async {
  final result = await Process.run('adb', [
    '-s',
    device,
    'forward',
    'tcp:0',
    'tcp:$devicePort',
  ]);
  if (result.exitCode != 0) {
    throw ProcessException(
      'adb',
      ['forward'],
      '${result.stderr}'.trim(),
      result.exitCode,
    );
  }
  final hostPort = int.parse('${result.stdout}'.trim());
  return VmPortForward(
    hostPort: hostPort,
    remove: () async {
      await Process.run('adb', [
        '-s',
        device,
        'forward',
        '--remove',
        'tcp:$hostPort',
      ]);
    },
  );
}

Future<FlutterLogsSession> _startFlutterLogsProcess(String device) async {
  final process = await Process.start('flutter', ['logs', '-d', device]);
  return FlutterLogsSession(
    stdout: process.stdout,
    stderr: process.stderr,
    stop: process.kill,
  );
}

/// Connects to the VM service and emits formatted Logging events.
Future<VmLogConnection> connectDartVmServiceLog(Uri httpUri) async {
  final service = await vmServiceConnectUri(dartVmServiceWebSocketUri(httpUri));
  await service.streamListen(EventStreams.kLogging);
  final controller = StreamController<String>();
  var chain = Future<void>.value();
  final subscription = service.onLoggingEvent.listen((event) {
    chain = chain.then((_) async {
      if (controller.isClosed) return;
      try {
        final line = await _formatDartVmLogEvent(service, event);
        if (line == null || controller.isClosed) return;
        controller.add(line);
      } catch (_) {}
    });
  }, onError: (_) {});
  return _DartVmLogConnection(
    lines: controller.stream,
    close: () async {
      await subscription.cancel();
      try {
        await chain;
      } catch (_) {}
      await service.dispose();
      if (!controller.isClosed) await controller.close();
    },
  );
}

Future<String?> _formatDartVmLogEvent(VmService service, Event event) async {
  final record = event.logRecord;
  if (record == null) return null;
  final isolateId = event.isolate?.id;
  final message = await _readString(service, isolateId, record.message);
  if (message == null || message.isEmpty) return null;
  return formatDartDeveloperLog(
    loggerName: await _readString(service, isolateId, record.loggerName),
    message: message,
    error: await _readString(service, isolateId, record.error),
    stackTrace: await _readString(service, isolateId, record.stackTrace),
  );
}

Future<String?> _readString(
  VmService service,
  String? isolateId,
  InstanceRef? ref,
) async {
  if (ref == null || ref.kind != 'String') return null;
  final preview = ref.valueAsString;
  if (preview != null && ref.valueAsStringIsTruncated != true) return preview;
  final id = ref.id;
  if (isolateId == null || id == null) return preview;
  try {
    final obj = await service.getObject(isolateId, id);
    if (obj is! Instance) return preview;
    final value = obj.valueAsString;
    final length = obj.length;
    if (value != null &&
        obj.valueAsStringIsTruncated == true &&
        length != null &&
        length > value.length) {
      final count = length > 65536 ? 65536 : length;
      final full = await service.getObject(isolateId, id, count: count);
      if (full is Instance && full.valueAsString != null) {
        return full.valueAsString;
      }
    }
    return value ?? preview;
  } catch (_) {
    return preview;
  }
}
