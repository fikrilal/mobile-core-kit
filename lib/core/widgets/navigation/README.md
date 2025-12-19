# AppBottomNavBar

Small wrapper around Material 3 `NavigationBar` so the app has one place to tweak
bottom navigation styling while keeping routing logic outside UI components.

## Usage

```dart
import 'package:mobile_core_kit/core/widgets/navigation/navigation.dart';

AppBottomNavBar(
  currentIndex: index,
  onTap: (i) => setState(() => index = i),
  items: const [
    AppBottomNavItem(label: 'Home', icon: Icons.home_outlined),
    AppBottomNavItem(label: 'Profile', icon: Icons.person_outline),
  ],
);
```

