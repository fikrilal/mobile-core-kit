// Field component public API.
//
// This barrel exports only the design-system types. Avoid re-exporting Flutter
// SDK symbols to keep imports explicit in feature code.

export 'app_textfield.dart';
export '../common/app_haptic_feedback.dart' show AppHapticFeedback;
export 'field_variants.dart'
    show FieldVariant, FieldSize, FieldState, FieldType, LabelPosition;
