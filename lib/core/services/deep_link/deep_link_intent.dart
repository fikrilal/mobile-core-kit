class DeepLinkIntent {
  const DeepLinkIntent({
    required this.location,
    required this.receivedAt,
    this.source,
  });

  /// GoRouter location (path + optional query), e.g. `/profile?tab=security`.
  final String location;

  /// When this intent was received (used for TTL expiry).
  final DateTime receivedAt;

  /// Optional tag for observability (e.g. `https`, `push`, `test`).
  final String? source;
}
