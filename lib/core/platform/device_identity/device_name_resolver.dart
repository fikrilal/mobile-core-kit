abstract interface class DeviceNameResolver {
  /// Returns a human-friendly, non-PII device name suitable for session lists.
  ///
  /// This value is best-effort and may be null on platforms where the name
  /// cannot be resolved safely.
  Future<String?> resolve();
}
