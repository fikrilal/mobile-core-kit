enum MediaPickErrorCode {
  cameraPermissionDenied,
  photoPermissionDenied,
  unavailable,
  invalidImage,
  unsupportedFormat,
  tooLargeAfterProcessing,
  unexpected,
}

class MediaPickException implements Exception {
  const MediaPickException(this.code, {this.message, this.cause});

  final MediaPickErrorCode code;
  final String? message;
  final Object? cause;

  @override
  String toString() => 'MediaPickException(code=$code, message=$message)';
}
