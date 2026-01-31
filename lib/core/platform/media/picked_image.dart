import 'dart:typed_data';

class PickedImage {
  const PickedImage({
    required this.bytes,
    required this.contentType,
    this.fileName,
  });

  final Uint8List bytes;
  final String contentType;
  final String? fileName;
}
