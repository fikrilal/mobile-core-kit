import 'dart:math' as math;

import 'package:flutter/material.dart';

/// WCAG 2.x contrast ratio between two colors (alpha is ignored).
///
/// Ratio is `(L1 + 0.05) / (L2 + 0.05)` where `L1` is the lighter luminance.
double wcagContrastRatio(Color a, Color b) {
  final l1 = _relativeLuminance(a);
  final l2 = _relativeLuminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

double _relativeLuminance(Color color) {
  // Relative luminance for sRGB as defined by WCAG 2.x:
  // https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  //
  // The coefficients are the standard ITU‑R BT.709 luma weights for linear
  // RGB: 0.2126 R + 0.7152 G + 0.0722 B.
  final r = _srgbToLinear(color.r);
  final g = _srgbToLinear(color.g);
  final b = _srgbToLinear(color.b);
  return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
}

double _srgbToLinear(double channel) {
  if (channel <= 0.03928) return channel / 12.92;
  return math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}
