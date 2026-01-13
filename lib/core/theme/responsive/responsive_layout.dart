import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveLayout {
  ResponsiveLayout._();

  // Device type detection
  static bool isMobile(BuildContext context) =>
      Breakpoints.getBreakpoint(MediaQuery.of(context).size.width) ==
      Breakpoint.mobile;

  static bool isTablet(BuildContext context) =>
      Breakpoints.getBreakpoint(MediaQuery.of(context).size.width) ==
      Breakpoint.tablet;

  static bool isDesktop(BuildContext context) =>
      Breakpoints.getBreakpoint(MediaQuery.of(context).size.width) ==
      Breakpoint.desktop;

  // Get current device type as enum
  static DeviceType getDeviceType(BuildContext context) {
    if (isMobile(context)) return DeviceType.mobile;
    if (isTablet(context)) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Responsive builder to render different widgets based on screen size
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  // Value selector based on screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

enum DeviceType { mobile, tablet, desktop }
