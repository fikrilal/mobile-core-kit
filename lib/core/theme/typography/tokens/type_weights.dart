import 'package:flutter/material.dart';

/// Defines the font weights used throughout the typography system.
///
/// These weights provide a clear hierarchy and consistent weight options
/// across the application, following common industry practices.

class TypeWeights {
  TypeWeights._();

  // Standard weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Semantic mappings (used for specific text roles)
  static const FontWeight displayWeight = bold;
  static const FontWeight headlineWeight = semiBold;
  static const FontWeight titleWeight = semiBold;
  static const FontWeight bodyWeight = regular;
  static const FontWeight labelWeight = medium;

  // Get weight based on the provided variant name
  static FontWeight fromVariant(String variant) {
    switch (variant) {
      case 'thin':
        return thin;
      case 'extraLight':
        return extraLight;
      case 'light':
        return light;
      case 'regular':
        return regular;
      case 'medium':
        return medium;
      case 'semiBold':
        return semiBold;
      case 'bold':
        return bold;
      case 'extraBold':
        return extraBold;
      case 'black':
        return black;
      default:
        return regular;
    }
  }
}
