import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:mobile_core_kit/core/services/media/media_pick_exception.dart';

class ImageBytesOptimizer {
  const ImageBytesOptimizer({
    this.maxBytes = 5_000_000,
    this.maxDimension = 1080,
    this.initialJpegQuality = 85,
    this.minJpegQuality = 60,
    this.dimensionStep = 0.85,
    this.qualityStep = 5,
    this.minDimension = 256,
  });

  final int maxBytes;
  final int maxDimension;
  final int initialJpegQuality;
  final int minJpegQuality;
  final double dimensionStep;
  final int qualityStep;
  final int minDimension;

  /// Decodes [input] into pixels, applies orientation, resizes, and encodes to
  /// JPEG until it fits under [maxBytes].
  ///
  /// Throws [MediaPickException] when the bytes can't be processed.
  Uint8List optimizeToJpeg(Uint8List input) {
    if (input.isEmpty) {
      throw const MediaPickException(MediaPickErrorCode.invalidImage);
    }

    final decoded = img.decodeImage(input);
    if (decoded == null) {
      throw const MediaPickException(MediaPickErrorCode.unsupportedFormat);
    }

    var image = img.bakeOrientation(decoded);
    image = _resizeToMaxDimension(image, maxDimension);

    Uint8List? bestEffort;

    while (true) {
      for (
        var quality = initialJpegQuality;
        quality >= minJpegQuality;
        quality -= qualityStep
      ) {
        final encoded = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );
        bestEffort = encoded;
        if (encoded.lengthInBytes <= maxBytes) return encoded;
      }

      final canDownscaleFurther =
          image.width > minDimension || image.height > minDimension;
      if (!canDownscaleFurther) {
        throw MediaPickException(
          MediaPickErrorCode.tooLargeAfterProcessing,
          message: 'Unable to compress image below $maxBytes bytes.',
          cause: bestEffort,
        );
      }

      final nextWidth = (image.width * dimensionStep).round().clamp(
        minDimension,
        image.width,
      );
      final nextHeight = (image.height * dimensionStep).round().clamp(
        minDimension,
        image.height,
      );
      image = img.copyResize(
        image,
        width: nextWidth,
        height: nextHeight,
        interpolation: img.Interpolation.average,
      );
    }
  }

  static img.Image _resizeToMaxDimension(img.Image image, int maxDimension) {
    final largestSide = image.width > image.height ? image.width : image.height;
    if (largestSide <= maxDimension) return image;

    final scale = maxDimension / largestSide;
    final nextWidth = (image.width * scale).round().clamp(1, image.width);
    final nextHeight = (image.height * scale).round().clamp(1, image.height);

    return img.copyResize(
      image,
      width: nextWidth,
      height: nextHeight,
      interpolation: img.Interpolation.average,
    );
  }
}
