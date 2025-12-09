# Flutter Responsiveness Implementation Guide

This guide documents our approach to responsive design in Flutter, following industry best practices used by large tech companies. Our implementation focuses on consistent spacing, layout changes at breakpoints, and selective scaling only where appropriate.

## Core Principles

Our responsive design system follows these key principles:

1. **Fixed spacing and sizing values** - We use a consistent set of values that don't scale
2. **Layout changes at breakpoints** - Different layouts for mobile, tablet, and desktop
3. **Selective scaling for specific UI elements** - Applied only where proportional scaling enhances UX
4. **Consistent component sizing** - Touch targets and key UI elements maintain consistent dimensions

## Folder Structure

```
lib/
└── core/
    └── theme/
        └── responsive/
            ├── breakpoints.dart
            ├── spacing.dart
            ├── sizing.dart
            ├── responsive_layout.dart
            ├── screen_utils.dart
            └── responsive_container.dart
```

## Class Documentation

### Breakpoints

`breakpoints.dart` defines standard screen width breakpoints that determine when layouts change.

```dart
class Breakpoints {
  // Standard breakpoints
  static const double xs = 0;       // Extra small screen
  static const double sm = 600;     // Small screen / phone
  static const double md = 900;     // Medium screen / tablet
  static const double lg = 1200;    // Large screen / desktop
  static const double xl = 1536;    // Extra large screen
}
```

**Usage:**
```dart
// Check if current screen width is above tablet breakpoint
if (MediaQuery.of(context).size.width >= Breakpoints.md) {
  // Use tablet layout
}
```

### AppSpacing

`spacing.dart` provides a comprehensive spacing system with fixed values that change at different breakpoints.

```dart
class AppSpacing {
  // Fixed spacing values (in logical pixels)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  // ... more spacing values ...
  
  // Methods that return different spacing values based on screen size
  static EdgeInsets screenPadding(BuildContext context) { ... }
  static EdgeInsets contentPadding(BuildContext context) { ... }
  static double horizontalSpacing(BuildContext context) { ... }
  static double sectionSpacing(BuildContext context) { ... }
}
```

**Usage:**
```dart
// Fixed spacing that doesn't change
SizedBox(height: AppSpacing.space16)

// Spacing that changes based on screen size
Padding(
  padding: AppSpacing.screenPadding(context),
  child: MyContent(),
)
```

### AppSizing

`sizing.dart` contains component sizes and dimensions that adapt to different screen sizes.

```dart
class AppSizing {
  // Fixed component sizes
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  
  // Methods that return different values based on screen size
  static double maxContentWidth(BuildContext context) { ... }
  static int gridColumns(BuildContext context) { ... }
  static double heroHeight(BuildContext context) { ... }
  static double modalWidth(BuildContext context) { ... }
}
```

**Usage:**
```dart
// Use for buttons with consistent sizing
SizedBox(
  height: AppSizing.buttonHeightMedium,
  child: ElevatedButton(...),
)

// Get appropriate grid column count for current screen
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: AppSizing.gridColumns(context),
  ),
)
```

### ResponsiveLayout

`responsive_layout.dart` provides helper methods to determine device type and render different layouts.

```dart
class ResponsiveLayout {
  // Device type detection
  static bool isMobile(BuildContext context) { ... }
  static bool isTablet(BuildContext context) { ... }
  static bool isDesktop(BuildContext context) { ... }
  
  // Get current device type as enum
  static DeviceType getDeviceType(BuildContext context) { ... }
  
  // Builder method to render different widgets based on screen size
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) { ... }
  
  // Value selector based on screen size
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) { ... }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}
```

**Usage:**
```dart
// Render different layouts based on screen size
ResponsiveLayout.builder(
  context: context,
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

// Select different values based on screen size
final spacing = ResponsiveLayout.value(
  context: context,
  mobile: 8.0,
  tablet: 16.0,
  desktop: 24.0,
)
```

### ScreenUtils

`screen_utils.dart` provides extension methods on BuildContext for easy access to screen properties.

```dart
extension ScreenUtils on BuildContext {
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Device type checks
  bool get isMobile => screenWidth < Breakpoints.sm;
  bool get isTablet => screenWidth >= Breakpoints.sm && screenWidth < Breakpoints.lg;
  bool get isDesktop => screenWidth >= Breakpoints.lg;
  
  // Orientation checks
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  // Screen size percentages
  double percentWidth(double percent) => screenWidth * percent;
  double percentHeight(double percent) => screenHeight * percent;
}
```

**Usage:**
```dart
// Check device type
if (context.isMobile) {
  // Mobile-specific code
}

// Use screen dimensions
Container(
  width: context.screenWidth,
  height: context.percentHeight(0.3), // 30% of screen height
)
```

### ResponsiveContainer

`responsive_container.dart` is a widget that handles responsive content width constraints.

```dart
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool centerContent;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? maxWidth;
  
  // Implementation...
}
```

**Usage:**
```dart
ResponsiveContainer(
  child: ListView(
    children: [
      // Content will be constrained to appropriate max width
      // based on screen size and centered in larger screens
    ],
  ),
)
```

## Common Patterns and Usage Examples

### 1. Responsive Page Layout

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      // Use responsive layout to show different layouts based on screen size
      body: ResponsiveLayout.builder(
        context: context,
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }
  
  Widget _buildMobileLayout() {
    return ListView(/* ... */);
  }
  
  Widget _buildTabletLayout() {
    return Row(/* ... */);
  }
  
  Widget _buildDesktopLayout() {
    return Row(/* ... */);
  }
}
```

### 2. Responsive Grid Layout

```dart
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  
  const ProductGrid({required this.products});
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: AppSpacing.screenPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Number of columns changes based on screen size
        crossAxisCount: AppSizing.gridColumns(context),
        childAspectRatio: 0.7,
        // Spacing between items changes based on screen size
        crossAxisSpacing: AppSpacing.horizontalSpacing(context),
        mainAxisSpacing: AppSpacing.horizontalSpacing(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductCard(products[index]),
    );
  }
}
```

### 3. Responsive Navigation Pattern

```dart
class MainLayout extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  
  const MainLayout({
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });
  
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    // Use extension methods for device type checks
    final isMobileDevice = context.isMobile;
    final isDesktopDevice = context.isDesktop;
    
    return Scaffold(
      body: Row(
        children: [
          // Show navigation rail on tablet/desktop
          if (!isMobileDevice)
            NavigationRail(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              // Extended on desktop, compact on tablet
              extended: isDesktopDevice,
              destinations: _buildDestinations(),
            ),
          // Main content
          Expanded(child: widget.body),
        ],
      ),
      // Show bottom navigation on mobile only
      bottomNavigationBar: isMobileDevice
          ? NavigationBar(
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: _buildDestinations(),
            )
          : null,
    );
  }
  
  List<Widget> _buildDestinations() {
    // Navigation destinations
  }
}
```

### 4. Content with Responsive Container

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      // Use ResponsiveContainer to constrain content width
      body: ResponsiveContainer(
        child: ListView(
          children: [
            // User profile information
            UserInfo(),
            
            SizedBox(height: AppSpacing.space24),
            
            // Activity feed
            ActivityFeed(),
          ],
        ),
      ),
    );
  }
}
```

### 5. Responsive Typography

Our typography is defined with fixed font sizes, but you can adapt which style is used based on screen size:

```dart
Text(
  'Welcome to our app',
  style: context.isDesktop
      ? Theme.of(context).textTheme.headlineLarge
      : Theme.of(context).textTheme.headlineSmall,
)
```

## Best Practices

1. **Use fixed spacing values consistently** - Always use the spacing values from `AppSpacing` rather than arbitrary numbers

2. **Change layouts at breakpoints** - Use different layouts for different screen sizes rather than trying to scale a single layout

3. **Keep touch targets consistent sizes** - Buttons, form fields, and other interactive elements should maintain consistent sizes for usability

4. **Use selective scaling sparingly** - Only use percentage-based scaling for elements where proportions are more important than consistent sizing (like hero images)

5. **Think in terms of device classes** - Design for mobile, tablet, and desktop as distinct layouts rather than trying to handle every possible screen size individually

6. **Test on real devices** - Always test your responsive UI on actual devices or accurate emulators to ensure it works as expected

## Common Issues and Solutions

### Issue: Layout looks cramped on small screens

**Solution:** Use `AppSpacing.screenPadding(context)` which provides appropriate padding for each screen size, and ensure all text is properly wrapped.

### Issue: Content is too wide on large screens

**Solution:** Use `ResponsiveContainer` to constrain content to appropriate max widths, or set explicit max width using `AppSizing.maxContentWidth(context)`.

### Issue: Grid items are too small or large

**Solution:** Adjust the number of columns using `AppSizing.gridColumns(context)` and ensure appropriate spacing between items with `AppSpacing.horizontalSpacing(context)`.

### Issue: Navigation doesn't work well across devices

**Solution:** Use the responsive navigation pattern shown above, with bottom navigation on mobile and side navigation on larger devices.

## Conclusion

By following these responsive design patterns, we can create Flutter applications that work well across all device sizes while maintaining consistency and usability. This approach balances the need for adaptability with the benefits of a structured design system.
