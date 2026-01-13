import 'package:flutter/foundation.dart';

import '../size_classes.dart';

enum SurfaceKind { reading, form, settings, dashboard, media, fullBleed }

@immutable
class SurfaceTokens {
  const SurfaceTokens({required this.contentMaxWidth});

  final double? contentMaxWidth;

  @override
  bool operator ==(Object other) =>
      other is SurfaceTokens && other.contentMaxWidth == contentMaxWidth;

  @override
  int get hashCode => contentMaxWidth.hashCode;
}

class SurfaceTokenTable {
  SurfaceTokenTable._();

  static SurfaceTokens resolve({
    required SurfaceKind kind,
    required WindowWidthClass widthClass,
  }) {
    switch (kind) {
      case SurfaceKind.fullBleed:
        return const SurfaceTokens(contentMaxWidth: null);

      case SurfaceKind.reading:
        return switch (widthClass) {
          WindowWidthClass.compact => const SurfaceTokens(
            contentMaxWidth: null,
          ),
          _ => const SurfaceTokens(contentMaxWidth: 720),
        };

      case SurfaceKind.form:
      case SurfaceKind.settings:
        return switch (widthClass) {
          WindowWidthClass.compact => const SurfaceTokens(
            contentMaxWidth: null,
          ),
          _ => const SurfaceTokens(contentMaxWidth: 720),
        };

      case SurfaceKind.dashboard:
        return switch (widthClass) {
          WindowWidthClass.compact => const SurfaceTokens(
            contentMaxWidth: null,
          ),
          WindowWidthClass.medium => const SurfaceTokens(contentMaxWidth: 900),
          WindowWidthClass.expanded => const SurfaceTokens(
            contentMaxWidth: 1100,
          ),
          WindowWidthClass.large => const SurfaceTokens(contentMaxWidth: 1200),
          WindowWidthClass.extraLarge => const SurfaceTokens(
            contentMaxWidth: 1200,
          ),
        };

      case SurfaceKind.media:
        return switch (widthClass) {
          WindowWidthClass.compact => const SurfaceTokens(
            contentMaxWidth: null,
          ),
          WindowWidthClass.medium => const SurfaceTokens(contentMaxWidth: 960),
          _ => const SurfaceTokens(contentMaxWidth: 1200),
        };
    }
  }
}
