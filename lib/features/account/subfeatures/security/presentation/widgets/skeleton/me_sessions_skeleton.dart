import 'package:flutter/material.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/radii.dart';
import 'package:mobile_core_kit/core/design_system/theme/tokens/spacing.dart';
import 'package:mobile_core_kit/core/design_system/widgets/shimmer/shimmer.dart';

class MeSessionsSkeleton extends StatelessWidget {
  const MeSessionsSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ShimmerComponent(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
        itemBuilder: (_, __) => _SkeletonCard(),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context).colorScheme.surfaceContainerHigh;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.radius12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CirclePlaceholder(size: 32, color: placeholderColor),
                const SizedBox(width: AppSpacing.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LinePlaceholder(
                        width: double.infinity,
                        height: 16,
                        color: placeholderColor,
                      ),
                      const SizedBox(height: AppSpacing.space8),
                      _LinePlaceholder(
                        width: 160,
                        height: 12,
                        color: placeholderColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space8),
                _LinePlaceholder(
                  width: 72,
                  height: 24,
                  color: placeholderColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space12),
            _LinePlaceholder(
              width: double.infinity,
              height: 12,
              color: placeholderColor,
            ),
            const SizedBox(height: AppSpacing.space8),
            _LinePlaceholder(width: 220, height: 12, color: placeholderColor),
            const SizedBox(height: AppSpacing.space12),
            Align(
              alignment: Alignment.centerRight,
              child: _LinePlaceholder(
                width: 84,
                height: 32,
                color: placeholderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinePlaceholder extends StatelessWidget {
  const _LinePlaceholder({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.radius8),
      ),
    );
  }
}

class _CirclePlaceholder extends StatelessWidget {
  const _CirclePlaceholder({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
