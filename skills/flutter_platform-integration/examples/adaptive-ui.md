# Platform-Adaptive UI Examples

## Adaptive Widgets

### Platform-Adaptive Button
```dart
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PlatformButton({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

### Platform-Adaptive Dialog
```dart
Future<void> showPlatformDialog({
  required BuildContext context,
  required String title,
  required String content,
}) {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

### Platform-Adaptive Loading Indicator
```dart
class PlatformLoadingIndicator extends StatelessWidget {
  const PlatformLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return const CupertinoActivityIndicator();
    }
    return const CircularProgressIndicator();
  }
}
```

### Platform-Adaptive Switch
```dart
class PlatformSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PlatformSwitch({
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      );
    }
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}
```

## Platform-Specific Navigation

```dart
class PlatformApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.activeBlue,
        ),
        home: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
            ],
          ),
          tabBuilder: (context, index) {
            return index == 0 ? HomePage() : SettingsPage();
          },
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
```

## Platform Detection in Tests

```dart
import 'package:flutter/foundation.dart';

void testPlatformBehavior() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // Test iOS-specific behavior
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    // Test Android-specific behavior
  }
}
```
