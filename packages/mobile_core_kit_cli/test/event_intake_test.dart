import 'dart:convert';
import 'dart:io';

import 'package:mobile_core_kit_cli/src/events/event_intake.dart';
import 'package:mobile_core_kit_cli/src/events/event_receipt.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'task_fixture.dart';

void main() {
  test(
    'promotes one queued plan and deduplicates the accepted event',
    () async {
      final fixture = await _fixture();
      addTearDown(() => fixture.root.deleteSync(recursive: true));

      final first = await fixture.service.runOnce();

      expect(first.accepted, isTrue);
      expect(first.recovered, isFalse);
      expect(first.taskId, 'event-fixture-task');
      expect(fixture.beginCount, 1);
      expect(fixture.taskOwnedPaths, {_queuedPath, _activePath});
      expect(
        File(p.join(fixture.root.path, _queuedPath)).existsSync(),
        isFalse,
      );
      final active = File(p.join(fixture.root.path, _activePath));
      expect(active.readAsStringSync(), contains('**Status:** active'));

      final receipts = FileEventReceiptStore(fixture.root).list();
      expect(receipts, hasLength(1));
      expect(receipts.single.status, EventReceiptStatus.accepted);
      expect(receipts.single.activePlanPath, _activePath);
      if (!Platform.isWindows) {
        final mode =
            FileStat.statSync(
              p.join(
                fixture.root.path,
                '.tmp/mobilekit/events/${receipts.single.eventId}.json',
              ),
            ).mode &
            0x1ff;
        expect(mode, 0x180); // 0600
      }

      final duplicate = await fixture.service.runOnce();
      expect(duplicate.eventId, first.eventId);
      expect(duplicate.recovered, isTrue);
      expect(fixture.beginCount, 1);
    },
  );

  test('recovers one claimed event after activation interruption', () async {
    var failOnce = true;
    final fixture = await _fixture(
      begin: (path, _) async {
        if (failOnce) {
          failOnce = false;
          throw const TaskControlError('fixture.interrupted', 'interrupted');
        }
        return _beginResult(path);
      },
    );
    addTearDown(() => fixture.root.deleteSync(recursive: true));

    await expectLater(
      fixture.service.runOnce(),
      throwsA(_controlError('fixture.interrupted')),
    );
    expect(
      FileEventReceiptStore(fixture.root).list().single.status,
      EventReceiptStatus.claimed,
    );
    expect(File(p.join(fixture.root.path, _activePath)).existsSync(), isTrue);

    final recovered = await fixture.service.runOnce();
    expect(recovered.accepted, isTrue);
    expect(recovered.recovered, isTrue);
    expect(
      FileEventReceiptStore(fixture.root).list().single.status,
      EventReceiptStatus.accepted,
    );
  });

  test('refuses an unrelated active V2 plan', () async {
    final fixture = await _fixture();
    addTearDown(() => fixture.root.deleteSync(recursive: true));
    File(p.join(fixture.root.path, 'docs/exec-plans/active/unrelated.md'))
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        _plan(
          taskId: 'unrelated-task',
          status: 'active',
          queuedPath: 'docs/exec-plans/queued/unrelated.md',
          activePath: 'docs/exec-plans/active/unrelated.md',
        ),
      );

    await expectLater(
      fixture.service.runOnce(),
      throwsA(_controlError('event.plan-active')),
    );
    expect(fixture.beginCount, 0);
    expect(File(p.join(fixture.root.path, _queuedPath)).existsSync(), isTrue);
  });

  test('fails closed when claimed active content changes', () async {
    final fixture = await _fixture(
      begin: (_, _) async =>
          throw const TaskControlError('fixture.interrupted', 'interrupted'),
    );
    addTearDown(() => fixture.root.deleteSync(recursive: true));
    await expectLater(
      fixture.service.runOnce(),
      throwsA(isA<TaskControlError>()),
    );

    File(p.join(fixture.root.path, _activePath)).writeAsStringSync('changed');
    await expectLater(
      fixture.service.runOnce(),
      throwsA(_controlError('event.plan-mismatch')),
    );
  });

  test(
    'strict receipt parser rejects unknown fields and oversized files',
    () async {
      final root = Directory.systemTemp.createTempSync(
        'mobilekit_event_receipt_',
      );
      addTearDown(() => root.deleteSync(recursive: true));
      final store = FileEventReceiptStore(root);
      final receipt = _receipt();
      store.create(receipt);
      final path = File(
        p.join(root.path, '.tmp/mobilekit/events/${receipt.eventId}.json'),
      );
      final decoded = (jsonDecode(path.readAsStringSync()) as Map)
          .cast<String, Object?>();
      decoded['payload'] = 'untrusted';
      path.writeAsStringSync(jsonEncode(decoded));
      expect(
        () => store.read(receipt.eventId),
        throwsA(_controlError('event.receipt-invalid')),
      );

      path.writeAsStringSync(
        List.filled(FileEventReceiptStore.maximumBytes + 1, 'x').join(),
      );
      expect(
        () => store.read(receipt.eventId),
        throwsA(_controlError('event.receipt-too-large')),
      );
    },
  );
}

const _queuedPath = 'docs/exec-plans/queued/event.md';
const _activePath = 'docs/exec-plans/active/event.md';

Future<_EventFixture> _fixture({EventTaskBegin? begin}) async {
  final root = Directory.systemTemp.createTempSync('mobilekit_event_');
  File(p.join(root.path, _queuedPath))
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(_plan());
  Directory(
    p.join(root.path, 'docs/exec-plans/active'),
  ).createSync(recursive: true);
  Directory(
    p.join(root.path, 'lib/features/example'),
  ).createSync(recursive: true);
  late _EventFixture fixture;
  fixture = _EventFixture(root: root);
  fixture.service = EventIntakeService(
    root: root,
    controlRoot: root,
    beginTask: (path, taskOwnedPaths) async {
      fixture.beginCount += 1;
      fixture.taskOwnedPaths = taskOwnedPaths.toSet();
      return begin == null ? _beginResult(path) : begin(path, taskOwnedPaths);
    },
    now: () => DateTime.utc(2026, 8, 12, 12),
  );
  return fixture;
}

TaskBeginResult _beginResult(String path) => TaskBeginResult(
  taskId: 'event-fixture-task',
  planPath: path,
  baseRevision: List.filled(40, 'a').join(),
  declaredRisk: TaskRisk.low,
  preexistingPathCount: 0,
);

String _plan({
  String taskId = 'event-fixture-task',
  String status = 'queued',
  String queuedPath = _queuedPath,
  String activePath = _activePath,
}) => taskPlanFixture(
  taskId: taskId,
  status: status,
  risk: 'low',
  maximumRisk: 'low',
  allowedPaths: '$queuedPath, $activePath, lib/features/example/',
  oracleIds: null,
  impacts: validImpactFixture.replaceFirst(
    'UI/UX/accessibility: yes',
    'UI/UX/accessibility: no',
  ),
);

EventReceipt _receipt() => EventReceipt(
  eventId: List.filled(64, 'a').join(),
  status: EventReceiptStatus.claimed,
  taskId: 'event-fixture-task',
  queuedPlanPath: _queuedPath,
  activePlanPath: _activePath,
  queuedSourceHash: List.filled(64, 'b').join(),
  activeSourceHash: List.filled(64, 'c').join(),
  authorityHash: List.filled(64, 'd').join(),
  receivedAt: DateTime.utc(2026, 8, 12),
);

Matcher _controlError(String code) =>
    isA<TaskControlError>().having((error) => error.code, 'code', code);

class _EventFixture {
  _EventFixture({required this.root});

  final Directory root;
  late EventIntakeService service;
  var beginCount = 0;
  Set<String> taskOwnedPaths = const {};
}
