class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    // Support both page-based and offset-based pagination payloads.
    // Preferred keys: currentPage/page. Fallback: derive page from offset/limit.
    final dynamic pageKey = json['currentPage'] ?? json['page'];
    final int limit = (json['limit'] as num).toInt();
    final int total = (json['total'] as num).toInt();

    // Offset can be present when backend uses offset-based pagination.
    final int? offset = (json['offset'] as num?)?.toInt();
    final int page = pageKey is num
        ? pageKey.toInt()
        : ((offset ?? 0) ~/ (limit == 0 ? 1 : limit)) + 1;

    // Calculate totalPages if not provided.
    final int totalPages = (json['totalPages'] as num?)?.toInt() ??
        (total > 0 && limit > 0 ? (total / limit).ceil() : 0);

    // Calculate hasNext/hasPrev if not provided.
    final bool hasNext = json['hasNext'] is bool
        ? json['hasNext'] as bool
        : (((offset ?? ((page - 1) * limit)) + limit) < total);
    final bool hasPrev = json['hasPrev'] is bool
        ? json['hasPrev'] as bool
        : (page > 1);

    return PaginationMeta(
      page: page,
      limit: limit,
      total: total,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrev: hasPrev,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $page, limit: $limit, total: $total, '
        'totalPages: $totalPages, hasNext: $hasNext, hasPrev: $hasPrev)';
  }
}

class ApiPaginatedResult<T> {
  final List<T> items;
  final PaginationMeta pagination;
  final Map<String, dynamic>? additionalMeta;

  ApiPaginatedResult({
    required this.items,
    required this.pagination,
    this.additionalMeta,
  });

  factory ApiPaginatedResult.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) fromItemJson,
  }) {
    // Parse items from data array
    final itemsJson = json['data'] as List? ?? [];
    final items = itemsJson
        .map((item) => fromItemJson(item as Map<String, dynamic>))
        .toList();

    // Parse pagination from meta.pagination
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final paginationJson = meta['pagination'] as Map<String, dynamic>? ?? {};
    final pagination = PaginationMeta.fromJson(paginationJson);

    // Extract additional meta (excluding pagination)
    final additionalMeta = Map<String, dynamic>.from(meta);
    additionalMeta.remove('pagination');

    return ApiPaginatedResult<T>(
      items: items,
      pagination: pagination,
      additionalMeta: additionalMeta.isNotEmpty ? additionalMeta : null,
    );
  }

  /// Factory for backend envelope `{ data: [] , meta: { pagination: {...} } }`
  factory ApiPaginatedResult.fromEnvelope(
    Map<String, dynamic> envelope, {
    required T Function(Map<String, dynamic>) fromItemJson,
  }) {
    final itemsJson = envelope['data'] as List? ?? [];
    final items = itemsJson
        .map((e) => fromItemJson(e as Map<String, dynamic>))
        .toList();

    final meta = envelope['meta'] as Map<String, dynamic>? ?? {};
    final paginationJson = meta['pagination'] as Map<String, dynamic>? ?? {};
    final pagination = PaginationMeta.fromJson(paginationJson);

    final additionalMeta = Map<String, dynamic>.from(meta);
    additionalMeta.remove('pagination');

    return ApiPaginatedResult<T>(
      items: items,
      pagination: pagination,
      additionalMeta: additionalMeta.isNotEmpty ? additionalMeta : null,
    );
  }

  // Convenience getters
  int get totalItems => pagination.total;
  int get totalPages => pagination.totalPages;
  int get currentPage => pagination.page;
  int get limit => pagination.limit;
  bool get hasNext => pagination.hasNext;
  bool get hasPrev => pagination.hasPrev;

  // Check if this is the first page
  bool get isFirstPage => pagination.page == 1;

  // Check if this is the last page
  bool get isLastPage => !pagination.hasNext;

  // Calculate the range of items being displayed
  String get itemRange {
    final start = ((pagination.page - 1) * pagination.limit) + 1;
    final end = (pagination.page * pagination.limit).clamp(0, pagination.total);
    return '$start-$end of ${pagination.total}';
  }

  @override
  String toString() {
    return 'ApiPaginatedResult(items: ${items.length}, pagination: $pagination, '
        'additionalMeta: $additionalMeta)';
  }
}

extension PaginationMetaX on PaginationMeta {
  int get offset => (page - 1) * limit;
}
