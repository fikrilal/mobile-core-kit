import 'package:mobile_core_kit/core/network/api/api_paginated_result.dart';

/// Cursor-oriented domain pagination view.
class DomainCursorPagination {
  const DomainCursorPagination({required this.nextCursor, required this.limit});

  final String? nextCursor;
  final int? limit;

  bool get hasNext => (nextCursor ?? '').isNotEmpty;
}

extension ApiPaginatedResultX<T> on ApiPaginatedResult<T> {
  DomainCursorPagination toDomainCursorPagination() =>
      DomainCursorPagination(nextCursor: nextCursor, limit: limit);
}

/// Convenience container representing a paginated domain result.
class PaginatedDomain<E, X> {
  const PaginatedDomain({
    required this.items,
    required this.pagination,
    this.extra,
  });

  final List<E> items;
  final DomainCursorPagination pagination;
  final X? extra; // Feature-specific metadata mapped from additionalMeta
}

/// Maps an ApiPaginatedResult to a domain-friendly structure with items,
/// cursor-based pagination, and optional feature-specific extra data.
PaginatedDomain<E, X> mapPaginatedResult<T, E, X>({
  required ApiPaginatedResult<T> result,
  required E Function(T) itemMapper,
  X Function(Map<String, dynamic>? additionalMeta)? extraMapper,
}) {
  final items = result.items.map(itemMapper).toList(growable: false);
  final pagination = result.toDomainCursorPagination();
  final extra = extraMapper?.call(result.additionalMeta);
  return PaginatedDomain<E, X>(
    items: items,
    pagination: pagination,
    extra: extra,
  );
}
