import 'dart:io';

import 'package:mobile_core_kit_cli/src/events/event_receipt.dart';
import 'package:mobile_core_kit_cli/src/task/git_repository.dart';
import 'package:mobile_core_kit_cli/src/task/repository_mutation_lock.dart';
import 'package:mobile_core_kit_cli/src/task/task_plan.dart';
import 'package:mobile_core_kit_cli/src/task/task_service.dart';
import 'package:mobile_core_kit_cli/src/task/task_state.dart';
import 'package:path/path.dart' as p;

class EventIntakeResult {
  const EventIntakeResult._({
    required this.idleReason,
    this.eventId,
    this.taskId,
    this.activePlanPath,
    this.recovered = false,
  });

  const EventIntakeResult.accepted({
    required String eventId,
    required String taskId,
    required String activePlanPath,
    required bool recovered,
  }) : this._(
         idleReason: null,
         eventId: eventId,
         taskId: taskId,
         activePlanPath: activePlanPath,
         recovered: recovered,
       );

  const EventIntakeResult.idle(String reason) : this._(idleReason: reason);

  final String? idleReason;
  final String? eventId;
  final String? taskId;
  final String? activePlanPath;
  final bool recovered;

  bool get accepted => eventId != null;
}

class EventIntakeService {
  EventIntakeService({
    required this.root,
    required this.controlRoot,
    EventReceiptStore? receipts,
    Future<TaskBeginResult> Function(String planPath)? beginTask,
    TaskStateStore? states,
    RepositoryMutationLock? lock,
    DateTime Function()? now,
  }) : receipts = receipts ?? FileEventReceiptStore(controlRoot),
       states = states ?? FileTaskStateStore(controlRoot),
       beginTask =
           beginTask ??
           TaskService(
             root: root,
             stateStore: states ?? FileTaskStateStore(controlRoot),
           ).begin,
       lock = lock ?? RepositoryMutationLock(controlRoot),
       now = now ?? DateTime.now;

  static const maximumPlanBytes = 64 * 1024;

  final Directory root;
  final Directory controlRoot;
  final EventReceiptStore receipts;
  final Future<TaskBeginResult> Function(String planPath) beginTask;
  final TaskStateStore states;
  final RepositoryMutationLock lock;
  final DateTime Function() now;

  Future<EventIntakeResult> runOnce() {
    _requirePrimaryCheckout();
    return lock.protect(() async {
      final claimed = receipts
          .list()
          .where((receipt) => receipt.status == EventReceiptStatus.claimed)
          .toList();
      if (claimed.length > 1) {
        throw const TaskControlError(
          'event.recovery-ambiguous',
          'More than one claimed event exists; recovery is ambiguous.',
        );
      }
      if (claimed.isNotEmpty) {
        _assertRecoveryFlight(claimed.single);
        return _accept(claimed.single, recovered: true);
      }

      final accepted = _acceptedActiveReceipts();
      if (accepted.length > 1) {
        throw const TaskControlError(
          'event.accepted-ambiguous',
          'More than one accepted event matches an active V2 plan.',
        );
      }
      if (accepted.isNotEmpty) {
        final receipt = accepted.single;
        return EventIntakeResult.accepted(
          eventId: receipt.eventId,
          taskId: receipt.taskId,
          activePlanPath: receipt.activePlanPath,
          recovered: true,
        );
      }

      _assertNoActiveV2Plan();
      final candidates = _queuedPlans();
      if (candidates.isEmpty) {
        return const EventIntakeResult.idle('no-queued-plans');
      }
      var foundAccepted = false;
      for (final candidate in candidates) {
        final receipt = _receiptFor(candidate);
        final existing = receipts.read(receipt.eventId);
        if (existing?.status == EventReceiptStatus.accepted) {
          foundAccepted = true;
          continue;
        }
        if (existing != null) {
          return _accept(existing, recovered: true);
        }
        receipts.create(receipt);
        return _accept(receipt, recovered: false);
      }
      return EventIntakeResult.idle(
        foundAccepted ? 'all-events-accepted' : 'no-queued-plans',
      );
    });
  }

  Future<EventIntakeResult> _accept(
    EventReceipt receipt, {
    required bool recovered,
  }) async {
    if (receipt.status == EventReceiptStatus.accepted) {
      return EventIntakeResult.accepted(
        eventId: receipt.eventId,
        taskId: receipt.taskId,
        activePlanPath: receipt.activePlanPath,
        recovered: true,
      );
    }
    final activeSource = _activatePlan(receipt);
    final activePlan = parseTaskPlan(receipt.activePlanPath, activeSource);
    _assertReceiptMatches(receipt, activePlan, activeSource);
    try {
      await beginTask(receipt.activePlanPath);
    } on TaskControlError catch (error) {
      if (error.code != 'task.state-exists') rethrow;
      final state = states.read(receipt.taskId);
      if (state.taskId != receipt.taskId ||
          state.planPath != receipt.activePlanPath ||
          state.planSourceHash != receipt.activeSourceHash ||
          state.authorityHash != receipt.authorityHash ||
          state.lifecycle != TaskLifecycle.authorized) {
        throw const TaskControlError(
          'event.task-conflict',
          'Existing task state does not match the claimed event.',
        );
      }
    }
    receipts.write(receipt.acceptedAt(now().toUtc()));
    return EventIntakeResult.accepted(
      eventId: receipt.eventId,
      taskId: receipt.taskId,
      activePlanPath: receipt.activePlanPath,
      recovered: recovered,
    );
  }

  String _activatePlan(EventReceipt receipt) {
    final queuedFile = File(p.join(root.path, receipt.queuedPlanPath));
    final activeFile = File(p.join(root.path, receipt.activePlanPath));
    final queuedSource = _optionalRead(queuedFile);
    final activeSource = _optionalRead(activeFile);
    if (queuedSource == null && activeSource == null) {
      throw const TaskControlError(
        'event.plan-missing',
        'Claimed plan is missing from both queued and active folders.',
      );
    }
    final expectedActive = queuedSource == null
        ? activeSource!
        : _promote(queuedSource);
    if (sha256String(expectedActive) != receipt.activeSourceHash) {
      throw const TaskControlError(
        'event.plan-mismatch',
        'Active plan content no longer matches the event receipt.',
      );
    }
    if (queuedSource != null) {
      final queuedPlan = parseTaskPlan(receipt.queuedPlanPath, queuedSource);
      assertAllowedPathsStayInRepository(
        root,
        queuedPlan.boundaries.allowedPaths,
      );
      _assertReceiptMatches(receipt, queuedPlan, expectedActive);
    }
    if (activeSource != null && activeSource != expectedActive) {
      throw const TaskControlError(
        'event.active-plan-conflict',
        'Active plan destination conflicts with the claimed event.',
      );
    }
    if (activeSource == null) {
      activeFile.parent.createSync(recursive: true);
      final temporary = File('${activeFile.path}.tmp-$pid');
      try {
        temporary.writeAsStringSync(expectedActive, flush: true);
        if (activeFile.existsSync()) {
          throw const TaskControlError(
            'event.active-plan-conflict',
            'Active plan destination already exists.',
          );
        }
        temporary.renameSync(activeFile.path);
      } finally {
        if (temporary.existsSync()) temporary.deleteSync();
      }
    }
    if (queuedFile.existsSync()) queuedFile.deleteSync();
    return expectedActive;
  }

  List<_QueuedCandidate> _queuedPlans() {
    final directory = Directory(
      p.join(root.path, 'docs', 'exec-plans', 'queued'),
    );
    if (!directory.existsSync()) return const [];
    final files =
        directory
            .listSync(followLinks: false)
            .whereType<File>()
            .where((file) => file.path.endsWith('.md'))
            .toList()
          ..sort((left, right) => left.path.compareTo(right.path));
    return files.map((file) {
      final path = p.relative(file.path, from: root.path).replaceAll('\\', '/');
      final source = _read(file);
      final plan = parseTaskPlan(path, source);
      if (plan.status != TaskPlanStatus.queued) {
        throw const TaskControlError(
          'event.plan-not-queued',
          'Event intake found a non-queued plan in the queue.',
        );
      }
      assertAllowedPathsStayInRepository(root, plan.boundaries.allowedPaths);
      return _QueuedCandidate(plan: plan, source: source);
    }).toList();
  }

  EventReceipt _receiptFor(_QueuedCandidate candidate) {
    final activePath =
        'docs/exec-plans/active/${p.basename(candidate.plan.path)}';
    final activeSource = _promote(candidate.source);
    return EventReceipt(
      eventId: sha256String(
        'queued-plan\n${candidate.plan.taskId}\n${candidate.plan.sourceHash}',
      ),
      status: EventReceiptStatus.claimed,
      taskId: candidate.plan.taskId,
      queuedPlanPath: candidate.plan.path,
      activePlanPath: activePath,
      queuedSourceHash: candidate.plan.sourceHash,
      activeSourceHash: sha256String(activeSource),
      authorityHash: candidate.plan.authorityHash,
      receivedAt: now().toUtc(),
    );
  }

  void _assertReceiptMatches(
    EventReceipt receipt,
    TaskPlan plan,
    String activeSource,
  ) {
    if (plan.taskId != receipt.taskId ||
        plan.authorityHash != receipt.authorityHash ||
        (plan.status == TaskPlanStatus.queued &&
            plan.sourceHash != receipt.queuedSourceHash) ||
        sha256String(activeSource) != receipt.activeSourceHash) {
      throw const TaskControlError(
        'event.plan-mismatch',
        'Plan no longer matches the claimed event.',
      );
    }
  }

  void _assertNoActiveV2Plan() {
    final active = _activeV2Paths();
    if (active.isNotEmpty) {
      throw TaskControlError(
        'event.plan-active',
        'Event intake requires no active V2 plan; found ${active.join(', ')}.',
      );
    }
  }

  void _assertRecoveryFlight(EventReceipt receipt) {
    final unrelated = _activeV2Paths().where(
      (path) => path != receipt.activePlanPath,
    );
    if (unrelated.isNotEmpty) {
      throw const TaskControlError(
        'event.recovery-plan-conflict',
        'An unrelated V2 plan became active while the event was claimed.',
      );
    }
  }

  List<EventReceipt> _acceptedActiveReceipts() {
    final result = <EventReceipt>[];
    for (final receipt in receipts.list()) {
      if (receipt.status != EventReceiptStatus.accepted) continue;
      final source = _optionalRead(
        File(p.join(root.path, receipt.activePlanPath)),
      );
      if (source == null || sha256String(source) != receipt.activeSourceHash) {
        continue;
      }
      final plan = parseTaskPlan(receipt.activePlanPath, source);
      _assertReceiptMatches(receipt, plan, source);
      result.add(receipt);
    }
    return result;
  }

  List<String> _activeV2Paths() {
    final directory = Directory(
      p.join(root.path, 'docs', 'exec-plans', 'active'),
    );
    if (!directory.existsSync()) return const [];
    final result = <String>[];
    for (final entity
        in directory.listSync(followLinks: false).whereType<File>()) {
      if (!entity.path.endsWith('.md')) continue;
      final source = _read(entity);
      if (!RegExp(
        r'^\*\*Plan version:\*\*\s*2\s*$',
        multiLine: true,
      ).hasMatch(source)) {
        continue;
      }
      final path = p
          .relative(entity.path, from: root.path)
          .replaceAll('\\', '/');
      final plan = parseTaskPlan(path, source);
      if (plan.status == TaskPlanStatus.active) result.add(path);
    }
    result.sort();
    return result;
  }

  String _read(File file) {
    if (file.lengthSync() > maximumPlanBytes) {
      throw const TaskControlError(
        'event.plan-too-large',
        'Execution plan exceeds the event-intake size limit.',
      );
    }
    return file.readAsStringSync();
  }

  String? _optionalRead(File file) => file.existsSync() ? _read(file) : null;

  String _promote(String source) {
    final status = RegExp(
      r'^\*\*Status:\*\*\s*queued\s*$',
      multiLine: true,
      caseSensitive: false,
    );
    if (status.allMatches(source).length != 1) {
      throw const TaskControlError(
        'event.status-invalid',
        'Queued plan status is ambiguous.',
      );
    }
    return source.replaceFirst(status, '**Status:** active');
  }

  void _requirePrimaryCheckout() {
    if (p.canonicalize(root.path) != p.canonicalize(controlRoot.path)) {
      throw const TaskControlError(
        'event.primary-required',
        'Run event intake from the primary checkout.',
      );
    }
  }
}

class _QueuedCandidate {
  const _QueuedCandidate({required this.plan, required this.source});

  final TaskPlan plan;
  final String source;
}
