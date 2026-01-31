import 'package:flutter/material.dart';

/// Defines the font weights used throughout the typography system.
///
/// These weights provide a clear hierarchy and consistent weight options
/// across the application, following common industry practices.

class TypeWeights {
  TypeWeights._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Semantic mappings (used for specific text roles)
  static const FontWeight displayWeight = bold;
  static const FontWeight headlineWeight = semiBold;
  static const FontWeight titleWeight = semiBold;
  static const FontWeight bodyWeight = regular;
  static const FontWeight labelWeight = medium;
}
