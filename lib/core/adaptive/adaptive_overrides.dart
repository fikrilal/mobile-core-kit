// Governed escape hatches for rare adaptive overrides.
//
// Most product adaptation should be expressed via tokens/policies/widgets in
// `lib/core/adaptive/`. This file exists for exceptional flows that need a
// narrowly scoped override without forking the whole contract.
import 'package:flutter/widgets.dart';

import 'adaptive_scope.dart';
import 'adaptive_spec_builder.dart';
import 'policies/navigation_policy.dart';

/// A governed escape hatch for rare, per-screen adaptive overrides.
///
/// Prefer adding new tokens/policies/widgets to `lib/core/adaptive/` instead of
/// using this. If you need this, it should be reviewed.
///
/// This widget **does not** change size classes; it re-derives `LayoutSpec`
/// using the nearest `AdaptiveModel`'s classification and window size.
class AdaptiveOverrides extends StatelessWidget {
  const AdaptiveOverrides({super.key, required this.child, this.navigationPolicy});

  final Widget child;

  /// Overrides how navigation is derived for the subtree.
  ///
  /// Example: force no navigation for a full-screen flow even on tablets.
  final NavigationPolicy? navigationPolicy;

  @override
  Widget build(BuildContext context) {
    final policy = navigationPolicy;
    if (policy == null) return child;

    final parent = AdaptiveModel.of(context);

    final navigation = policy.derive(
      widthClass: parent.layout.widthClass,
      platform: parent.platform.platform,
      input: parent.input,
    );

    final layout = AdaptiveSpecBuilder.deriveLayout(
      constraints: BoxConstraints.tight(parent.layout.size),
      media: MediaQuery.of(context),
      widthClass: parent.layout.widthClass,
      heightClass: parent.layout.heightClass,
      orientation: parent.layout.orientation,
      input: parent.input,
      navigation: navigation,
    );

    return AdaptiveModel(spec: parent.copyWith(layout: layout), child: child);
  }
}
