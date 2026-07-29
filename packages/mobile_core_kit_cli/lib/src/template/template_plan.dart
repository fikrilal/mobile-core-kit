enum TemplatePlanStatus { changed, skipped, conflicted, external, generated }

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

class TemplatePlan {
  TemplatePlan({required Iterable<TemplatePlanItem> items})
    : items = List<TemplatePlanItem>.unmodifiable(items);

  final List<TemplatePlanItem> items;

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
