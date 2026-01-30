/// Normalized notification permission state used by template-level push logic.
///
/// This intentionally abstracts platform-specific enums (e.g. Firebase Messaging
/// `AuthorizationStatus`) so downstream apps can build UX without importing SDK
/// packages in feature code.
enum PushPermissionState {
  /// User has granted notifications permission.
  granted,

  /// User has denied notifications permission.
  denied,

  /// Permission was granted in a limited/provisional way (iOS provisional).
  provisional,

  /// The user hasn't made a decision yet (or the platform does not expose it).
  notDetermined,

  /// Push/permissions are not supported in this runtime (e.g. desktop, template
  /// policy disabled-by-default on web).
  notSupported,
}
