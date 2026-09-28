final _developerLogLine = RegExp(
  r'^\[[A-Za-z][A-Za-z0-9_]*\] ',
  multiLine: true,
);

const vmLogAttachedSignalId = 'vm-log-attached';

/// One registered journey fact. [contains] is a fixed substring, never a
/// captured log line.
class MaestroLogSignal {
  const MaestroLogSignal({required this.id, required this.contains});

  final String id;
  final String contains;
}

class MaestroLogSignalReport {
  const MaestroLogSignalReport({
    required this.vmLogAttached,
    required this.missingIds,
  });

  final bool vmLogAttached;
  final List<String> missingIds;

  bool get passed => vmLogAttached && missingIds.isEmpty;

  Map<String, Object?> toJson() => {
    'vmLogAttached': vmLogAttached,
    'missing': missingIds,
  };
}

/// Universal attach check plus the flow's own success substrings.
///
/// Missing ids name the signal. The matched log text is not returned.
MaestroLogSignalReport evaluateMaestroLog({
  required String log,
  required List<MaestroLogSignal> signals,
}) {
  final attached = _developerLogLine.hasMatch(log);
  return MaestroLogSignalReport(
    vmLogAttached: attached,
    missingIds: [
      if (!attached) vmLogAttachedSignalId,
      for (final signal in signals)
        if (!log.contains(signal.contains)) signal.id,
    ],
  );
}
