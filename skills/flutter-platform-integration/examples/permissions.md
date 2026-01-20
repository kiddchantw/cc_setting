# Permission Handling Examples

## Using permission_handler Package

### Permission Service
```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request single permission
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  // Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  // Check if all permissions granted
  static Future<bool> checkPermissions(List<Permission> permissions) async {
    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }
}
```

### Usage Examples

```dart
// Request camera permission
Future<void> takePicture() async {
  final hasPermission = await PermissionService.requestPermission(
    Permission.camera,
  );

  if (hasPermission) {
    // Open camera
  } else {
    // Show permission denied message
  }
}

// Request multiple permissions
Future<void> requestMediaPermissions() async {
  final statuses = await PermissionService.requestMultiplePermissions([
    Permission.camera,
    Permission.microphone,
    Permission.photos,
  ]);

  final allGranted = statuses.values.every((s) => s.isGranted);
  if (allGranted) {
    // All permissions granted
  }
}
```

### Permission Dialog with Rationale

```dart
Future<bool> requestLocationWithRationale(BuildContext context) async {
  final status = await Permission.location.status;

  if (status.isGranted) return true;

  if (status.isDenied) {
    // Show rationale dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'We need location access to show nearby stores. '
          'Your location data is never shared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
  }

  if (status.isPermanentlyDenied) {
    // Show settings dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is required. Please enable it in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  return false;
}
```

## Common Permission Types

| Permission | iOS Info.plist Key | Android Manifest |
|------------|-------------------|------------------|
| Camera | `NSCameraUsageDescription` | `android.permission.CAMERA` |
| Location | `NSLocationWhenInUseUsageDescription` | `ACCESS_FINE_LOCATION` |
| Photos | `NSPhotoLibraryUsageDescription` | `READ_EXTERNAL_STORAGE` |
| Microphone | `NSMicrophoneUsageDescription` | `RECORD_AUDIO` |
| Contacts | `NSContactsUsageDescription` | `READ_CONTACTS` |
| Notifications | - | `POST_NOTIFICATIONS` (Android 13+) |
