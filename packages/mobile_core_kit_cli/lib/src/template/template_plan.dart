enum TemplatePlanStatus { changed, skipped, conflicted, external, generated }

bool templateBytesEqual(List<int>? left, List<int> right) {
  if (left == null || left.length != right.length) return false;
  for (var index = 0; index < right.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

String templateContentFingerprint(List<int> bytes) {
  var hash = 0xcbf29ce484222325;
  for (final byte in bytes) {
    hash ^= byte;
    hash = (hash * 0x100000001b3) & 0xffffffffffffffff;
  }
  return bytes.length.toString() +
      ':' +
      hash.toRadixString(16).padLeft(16, '0');
}

class TemplatePlanItem {
  const TemplatePlanItem({
    required this.status,
    required this.target,
    required this.description,
  });

  final TemplatePlanStatus status;
  final String target;
  final String description;
}

class TemplateFileChange {
  TemplateFileChange({
    required this.relativePath,
    required List<int>? beforeBytes,
    required List<int> afterBytes,
  }) : beforeBytes = beforeBytes == null
           ? null
           : List<int>.unmodifiable(beforeBytes),
       afterBytes = List<int>.unmodifiable(afterBytes),
       beforeFingerprint = beforeBytes == null
           ? null
           : templateContentFingerprint(beforeBytes),
       afterFingerprint = templateContentFingerprint(afterBytes);

  final String relativePath;
  final List<int>? beforeBytes;
  final List<int> afterBytes;
  final String? beforeFingerprint;
  final String afterFingerprint;

  bool get hasChanges => !templateBytesEqual(beforeBytes, afterBytes);
}

class TemplatePlan {
  TemplatePlan({
    required Iterable<TemplatePlanItem> items,
    Iterable<TemplateFileChange> fileChanges = const [],
  }) : items = List<TemplatePlanItem>.unmodifiable(items),
       fileChanges = List<TemplateFileChange>.unmodifiable(fileChanges);

  final List<TemplatePlanItem> items;
  final List<TemplateFileChange> fileChanges;

  bool get hasChanges => items.any(
    (item) =>
        item.status == TemplatePlanStatus.changed ||
        item.status == TemplatePlanStatus.generated,
  );

  bool get hasConflicts =>
      items.any((item) => item.status == TemplatePlanStatus.conflicted);
}

enum TemplateLifecycleOutcome { applied, dryRun, skipped, failed }

class TemplateLifecycleResult {
  const TemplateLifecycleResult({required this.plan, required this.outcome});

  final TemplatePlan plan;
  final TemplateLifecycleOutcome outcome;

  int get exitCode => outcome == TemplateLifecycleOutcome.failed ? 1 : 0;
}
