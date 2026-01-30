class ApiPaginatedResult<T> {
  final List<T> items;
  final String? nextCursor;
  final int? limit;
  final Map<String, dynamic>? additionalMeta;

  ApiPaginatedResult({
    required this.items,
    this.nextCursor,
    this.limit,
    this.additionalMeta,
  });

  /// Factory for backend envelope `{ data: [], meta: { nextCursor?, limit? } }`.
  factory ApiPaginatedResult.fromEnvelope(
    Map<String, dynamic> envelope, {
    required T Function(Map<String, dynamic>) fromItemJson,
  }) {
    final itemsJson = envelope['data'] as List? ?? [];
    final items = itemsJson
        .map((e) => fromItemJson(e as Map<String, dynamic>))
        .toList();

    final meta = envelope['meta'] as Map<String, dynamic>? ?? {};
    final nextCursor = meta['nextCursor'] as String?;
    final limit = (meta['limit'] as num?)?.toInt();

    final additionalMeta = Map<String, dynamic>.from(meta);
    additionalMeta.remove('nextCursor');
    additionalMeta.remove('limit');

    return ApiPaginatedResult<T>(
      items: items,
      nextCursor: nextCursor,
      limit: limit,
      additionalMeta: additionalMeta.isNotEmpty ? additionalMeta : null,
    );
  }

  // Convenience getters
  bool get hasNext => (nextCursor ?? '').isNotEmpty;

  @override
  String toString() {
    return 'ApiPaginatedResult(items: ${items.length}, nextCursor: $nextCursor, limit: $limit, '
        'additionalMeta: $additionalMeta)';
  }
}
