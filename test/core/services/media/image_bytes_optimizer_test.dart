import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_core_kit/core/services/media/image_bytes_optimizer.dart';
import 'package:mobile_core_kit/core/services/media/media_pick_exception.dart';

void main() {
  test('optimizeToJpeg reduces a large image under the byte limit', () {
    // Generate a relatively hard-to-compress image (high-frequency noise).
    final image = img.Image(width: 2000, height: 2000);

    var seed = 123456789;
    int next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed;
    }

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final v = next() & 0xff;
        image.setPixelRgba(x, y, v, (v * 3) & 0xff, (v * 7) & 0xff, 255);
      }
    }

    final original = Uint8List.fromList(img.encodeJpg(image, quality: 100));
    expect(original.lengthInBytes, greaterThan(5_000_000));

    const optimizer = ImageBytesOptimizer(
      maxBytes: 5_000_000,
      maxDimension: 1080,
    );
    final optimized = optimizer.optimizeToJpeg(original);

    expect(optimized.lengthInBytes, lessThanOrEqualTo(5_000_000));
    expect(optimized.isNotEmpty, isTrue);
    // JPEG SOI marker: 0xFF 0xD8
    expect(optimized[0], 0xFF);
    expect(optimized[1], 0xD8);
  });

  test('optimizeToJpeg throws on empty input', () {
    const optimizer = ImageBytesOptimizer();
    expect(
      () => optimizer.optimizeToJpeg(Uint8List(0)),
      throwsA(
        isA<MediaPickException>().having(
          (e) => e.code,
          'code',
          MediaPickErrorCode.invalidImage,
        ),
      ),
    );
  });

  test('optimizeToJpeg throws on unsupported bytes', () {
    const optimizer = ImageBytesOptimizer();
    final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

    expect(
      () => optimizer.optimizeToJpeg(bytes),
      throwsA(
        isA<MediaPickException>().having(
          (e) => e.code,
          'code',
          MediaPickErrorCode.unsupportedFormat,
        ),
      ),
    );
  });
}
