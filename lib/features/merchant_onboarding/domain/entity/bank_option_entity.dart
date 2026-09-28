class BankOptionEntity {
  BankOptionEntity({
    required this.id,
    required this.label,
    required Set<String> supportedScheduleIds,
  }) : supportedScheduleIds = Set.unmodifiable(supportedScheduleIds);

  final String id;
  final String label;
  final Set<String> supportedScheduleIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankOptionEntity &&
          other.id == id &&
          other.label == label &&
          other.supportedScheduleIds.length == supportedScheduleIds.length &&
          other.supportedScheduleIds.containsAll(supportedScheduleIds);

  @override
  int get hashCode =>
      Object.hash(id, label, Object.hashAll(supportedScheduleIds));
}
