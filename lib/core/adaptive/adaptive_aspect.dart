/// Fine-grained dependency keys for [AdaptiveModel] (`InheritedModel`).
///
/// Each aspect corresponds to a sub-spec inside [AdaptiveSpec].
///
/// Prefer the most specific context accessor (e.g. `context.adaptiveLayout`)
/// so widgets rebuild only when that aspect changes.
enum AdaptiveAspect { layout, insets, text, motion, input, platform, foldable }
