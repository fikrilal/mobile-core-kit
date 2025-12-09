class StateOpacities {
  StateOpacities._();

  // Material-like state opacity guidelines
  static const double disabledContent = 0.38; // onSurface * 0.38
  static const double disabledContainer = 0.12; // surface/outline * 0.12

  static const double hover = 0.08;
  static const double focus = 0.12;
  static const double pressed = 0.12;
  static const double dragged = 0.16;
}

