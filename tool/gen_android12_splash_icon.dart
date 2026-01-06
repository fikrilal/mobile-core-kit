import 'dart:io';

import 'package:image/image.dart' as img;

bool _isBackgroundPixel(img.Pixel pixel, img.Color bg, {int tolerance = 24}) {
  final dr = (pixel.r.toInt() - bg.r.toInt()).abs();
  final dg = (pixel.g.toInt() - bg.g.toInt()).abs();
  final db = (pixel.b.toInt() - bg.b.toInt()).abs();
  return (dr + dg + db) <= tolerance;
}

img.Color _estimateBackgroundColor(img.Image image) {
  final corners = <img.Pixel>[
    image.getPixel(0, 0),
    image.getPixel(image.width - 1, 0),
    image.getPixel(0, image.height - 1),
    image.getPixel(image.width - 1, image.height - 1),
  ];

  var r = 0;
  var g = 0;
  var b = 0;
  for (final p in corners) {
    r += p.r.toInt();
    g += p.g.toInt();
    b += p.b.toInt();
  }
  final count = corners.length;
  return img.ColorRgb8(r ~/ count, g ~/ count, b ~/ count);
}

/// Removes a solid-ish background by flood-filling from the image edges.
///
/// This preserves interior dark details (e.g., eyes) because they are not
/// connected to the image border.
img.Image _removeEdgeConnectedBackground(
  img.Image source, {
  int tolerance = 24,
}) {
  final image = img.Image.from(source);
  final bg = _estimateBackgroundColor(image);

  final w = image.width;
  final h = image.height;
  final visited = List<bool>.filled(w * h, false);
  final queue = <int>[];

  void tryAdd(int x, int y) {
    final idx = y * w + x;
    if (visited[idx]) return;
    final p = image.getPixel(x, y);
    if (!_isBackgroundPixel(p, bg, tolerance: tolerance)) return;
    visited[idx] = true;
    queue.add(idx);
  }

  for (var x = 0; x < w; x++) {
    tryAdd(x, 0);
    tryAdd(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    tryAdd(0, y);
    tryAdd(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final idx = queue.removeLast();
    final x = idx % w;
    final y = idx ~/ w;

    final p = image.getPixel(x, y);
    image.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 0);

    if (x > 0) tryAdd(x - 1, y);
    if (x + 1 < w) tryAdd(x + 1, y);
    if (y > 0) tryAdd(x, y - 1);
    if (y + 1 < h) tryAdd(x, y + 1);
  }

  return image;
}

void main(List<String> args) {
  final inputPath = args.isNotEmpty
      ? args[0]
      : 'assets/logos/app/logo-icon-mono-black.png';
  final outputPath = args.length > 1
      ? args[1]
      : 'assets/logos/app/logo-icon-mono-black-android12.png';

  // Android 12 SplashScreen icon spec:
  // - Asset: 1152x1152
  // - Safe content: 768x768 centered (192px padding each side)
  const outSize = 1152;
  const safeSize = 768;

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input not found: $inputPath');
    exitCode = 2;
    return;
  }

  final bytes = inputFile.readAsBytesSync();
  final decoded = img.decodePng(bytes);
  if (decoded == null) {
    stderr.writeln('Failed to decode PNG: $inputPath');
    exitCode = 2;
    return;
  }

  final cutout = _removeEdgeConnectedBackground(decoded);

  final resized = img.copyResize(
    cutout,
    width: safeSize,
    height: safeSize,
    interpolation: img.Interpolation.average,
  );

  final canvas = img.Image(width: outSize, height: outSize, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  final offset = (outSize - safeSize) ~/ 2;
  img.compositeImage(canvas, resized, dstX: offset, dstY: offset);

  final outputFile = File(outputPath)..createSync(recursive: true);
  outputFile.writeAsBytesSync(img.encodePng(canvas));

  stdout.writeln('Wrote $outputPath ($outSize x $outSize, safe=$safeSize)');
}
