import 'dart:typed_data';

/// Raw profile image upload input submitted to the upload use case.
///
/// Values may be invalid. `ValidatedProfileImageUpload` owns the transition
/// to validated domain values before the repository boundary.
class ProfileImageUploadInput {
  const ProfileImageUploadInput({
    required this.bytes,
    required this.contentType,
    this.idempotencyKey,
  });

  final Uint8List bytes;
  final String contentType;
  final String? idempotencyKey;
}
