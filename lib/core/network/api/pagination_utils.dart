import 'api_paginated_result.dart';

/// Offset-oriented domain pagination view built from typed PaginationMeta.
class DomainOffsetPagination {
  const DomainOffsetPagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasNext,
    required this.hasPrev,
  });

  final int total;
  final int limit;
  final int offset;
  final bool hasNext;
  final bool hasPrev;

  factory DomainOffsetPagination.fromMeta(PaginationMeta meta) =>
      DomainOffsetPagination(
        total: meta.total,
        limit: meta.limit,
        offset: meta.offset,
        hasNext: meta.hasNext,
        hasPrev: meta.hasPrev,
      );
}

extension ApiPaginatedResultX<T> on ApiPaginatedResult<T> {
  /// Converts typed PaginationMeta into a domain offset-based view.
  DomainOffsetPagination toDomainOffsetPagination() =>
      DomainOffsetPagination.fromMeta(pagination);
}

/// Convenience container representing a paginated domain result.
class PaginatedDomain<E, X> {
  const PaginatedDomain({
    required this.items,
    required this.pagination,
    this.extra,
  });

  final List<E> items;
  final DomainOffsetPagination pagination;
  final X? extra; // Feature-specific metadata mapped from additionalMeta
}

/// Maps an ApiPaginatedResult to a domain-friendly structure with items,
/// offset-based pagination, and optional feature-specific extra data.
PaginatedDomain<E, X> mapPaginatedResult<T, E, X>({
  required ApiPaginatedResult<T> result,
  required E Function(T) itemMapper,
  X Function(Map<String, dynamic>? additionalMeta)? extraMapper,
}) {
  final items = result.items.map(itemMapper).toList(growable: false);
  final pagination = result.toDomainOffsetPagination();
  final extra = extraMapper?.call(result.additionalMeta);
  return PaginatedDomain<E, X>(
    items: items,
    pagination: pagination,
    extra: extra,
  );
}

