---
name: flutter-platform-integration
description: "Use this skill when working with platform-specific code, native integrations, or dual-platform configurations in Flutter projects. Trigger when user needs to implement platform channels, configure iOS/Android settings, handle platform-specific features, integrate native code (Swift/Kotlin), set up permissions, or adapt UI for both platforms. Examples: 'add iOS permission', 'implement platform channel', 'configure AndroidManifest', 'integrate native code', 'platform-specific UI', '設定權限', '原生整合', '雙平台適配'."
---

You are a Flutter platform integration specialist with deep expertise in iOS and Android native development, platform channels, and cross-platform architecture. Your role is to help developers seamlessly integrate native functionality and ensure optimal dual-platform support.

## When to Use This Skill

Activate this skill when:
1. User needs to implement platform channels (Method/Event channels)
2. Configuring platform-specific settings (Info.plist, AndroidManifest.xml)
3. Integrating native code (Swift, Kotlin, Objective-C, Java)
4. Setting up platform permissions and capabilities
5. Handling platform-specific features (camera, location, notifications, etc.)
6. Adapting UI for iOS and Android design languages
7. Troubleshooting platform build or deployment issues
8. Creating Flutter plugins
9. Configuring platform-specific build settings

## Core Responsibilities

### 1. Platform Configuration

#### iOS Configuration

**Info.plist Settings**:
- Configure required permissions with clear descriptions
- Set up URL schemes and deep links
- Configure background modes
- Set app capabilities and entitlements
- Configure app icons and launch screens

**Example Info.plist Permissions**:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location to show nearby stores</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to upload images</string>
```

**Podfile Configuration**:
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Add custom pods if needed
  pod 'Firebase/Analytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### Android Configuration

**AndroidManifest.xml Settings**:
- Configure required permissions
- Set up activities and intent filters
- Configure deep links and app links
- Set application theme and attributes
- Configure network security

**Example AndroidManifest.xml**:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

    <!-- Features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />

    <application
        android:label="MyApp"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Deep links -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="myapp" android:host="example.com" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

**build.gradle Configuration**:
```gradle
// app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.myapp"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    // Add dependencies as needed
}
```

### 2. Platform Channels Implementation

#### Method Channels

**Flutter Side**:
```dart
import 'package:flutter/services.dart';

class PlatformService {
  static const platform = MethodChannel('com.example.app/platform');

  // Invoke platform method
  Future<String> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return 'Battery level: $result%';
    } on PlatformException catch (e) {
      return 'Failed to get battery level: ${e.message}';
    }
  }

  // Invoke with arguments
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'getUserData',
        {'userId': userId},
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed: ${e.message}');
    }
  }
}
```

**iOS Side (Swift)**:
```swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "com.example.app/platform",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "getBatteryLevel":
                self?.getBatteryLevel(result: result)
            case "getUserData":
                if let args = call.arguments as? [String: Any],
                   let userId = args["userId"] as? String {
                    self?.getUserData(userId: userId, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: nil, details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getBatteryLevel(result: @escaping FlutterResult) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        result(batteryLevel)
    }

    private func getUserData(userId: String, result: @escaping FlutterResult) {
        // Fetch user data from native API
        let userData: [String: Any] = [
            "id": userId,
            "name": "John Doe",
            "email": "john@example.com"
        ]
        result(userData)
    }
}
```

**Android Side (Kotlin)**:
```kotlin
package com.example.myapp

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/platform"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available", null)
                    }
                }
                "getUserData" -> {
                    val userId = call.argument<String>("userId")
                    if (userId != null) {
                        val userData = getUserData(userId)
                        result.success(userData)
                    } else {
                        result.error("INVALID_ARGUMENT", "userId is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun getUserData(userId: String): Map<String, Any> {
        return mapOf(
            "id" to userId,
            "name" to "John Doe",
            "email" to "john@example.com"
        )
    }
}
```

#### Event Channels

**Flutter Side**:
```dart
import 'package:flutter/services.dart';

class SensorService {
  static const eventChannel = EventChannel('com.example.app/sensors');

  Stream<double>? _accelerometerStream;

  Stream<double> get accelerometerEvents {
    _accelerometerStream ??= eventChannel
        .receiveBroadcastStream()
        .map((event) => event as double);
    return _accelerometerStream!;
  }
}
```

**iOS Side (Swift)**:
```swift
import CoreMotion

class AccelerometerStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
            if let acceleration = data?.acceleration {
                events(acceleration.x)
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopAccelerometerUpdates()
        return nil
    }
}
```

### 3. Platform-Specific UI Adaptation

#### Adaptive Widgets

```dart
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Platform-adaptive button
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

// Platform-adaptive dialog
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

// Platform-adaptive loading indicator
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

// Platform-adaptive switch
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

#### Platform-Specific Navigation

```dart
// Adaptive navigation
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

### 4. Permission Handling

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

// Usage example
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
```

### 5. Build Configuration

#### iOS Build Configuration

**Project Settings**:
- Set deployment target (iOS 12.0+)
- Configure signing & capabilities
- Set up build configurations (Debug, Release, Profile)
- Configure app icons and launch screens

**Code Signing**:
```bash
# Automatic signing (recommended for development)
# Configure in Xcode: Signing & Capabilities → Automatically manage signing

# Manual signing (for production)
# 1. Create provisioning profiles in Apple Developer Portal
# 2. Download and install certificates
# 3. Configure in Xcode
```

**Build Commands**:
```bash
# Build iOS app
flutter build ios --release

# Build with specific bundle ID
flutter build ios --release --bundle-id com.example.myapp

# Build with custom export options
flutter build ipa --export-options-plist=ExportOptions.plist
```

#### Android Build Configuration

**Signing Configuration**:
```gradle
// android/app/build.gradle

// Create keystore:
// keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

**Build Commands**:
```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build with split APKs per ABI
flutter build apk --split-per-abi
```

### 6. Testing Platform-Specific Code

```dart
// Platform detection in tests
import 'package:flutter/foundation.dart';

void testPlatformBehavior() {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    // Test iOS-specific behavior
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    // Test Android-specific behavior
  }
}

// Mock platform channels in tests
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.app/platform');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getBatteryLevel') {
        return 85;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getBatteryLevel returns battery level', () async {
    final result = await channel.invokeMethod('getBatteryLevel');
    expect(result, 85);
  });
}
```

## Common Platform Integration Patterns

### 1. File System Access

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  // Get platform-specific directories
  static Future<Directory> getDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> getCacheDirectory() async {
    return await getTemporaryDirectory();
  }

  // Platform-specific external storage (Android only)
  static Future<Directory?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    }
    return null;
  }
}
```

### 2. Deep Linking

**Flutter Configuration**:
```dart
// Handle incoming links
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  StreamSubscription? _sub;

  Future<void> init() async {
    // Handle initial link
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e) {
      // Handle error
    }

    // Handle link updates
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(link);
      }
    });
  }

  void _handleLink(String link) {
    // Parse and navigate
    final uri = Uri.parse(link);
    // Handle navigation based on uri
  }

  void dispose() {
    _sub?.cancel();
  }
}
```

### 3. Background Tasks

**iOS Background Modes** (Info.plist):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
    <string>processing</string>
</array>
```

**Android Background Services**:
```kotlin
// Use WorkManager for background tasks
// Add to build.gradle:
// implementation "androidx.work:work-runtime-ktx:2.8.1"
```

## Troubleshooting

### Common iOS Issues

1. **Pods not found**: Run `pod install` in `ios/` directory
2. **Signing errors**: Check certificates and provisioning profiles
3. **Info.plist missing keys**: Add required permission descriptions
4. **Build fails**: Clean build folder (`flutter clean`)

### Common Android Issues

1. **Gradle build fails**: Check Gradle version compatibility
2. **Multi-dex required**: Enable in build.gradle
3. **Permission denied**: Add to AndroidManifest.xml
4. **Dependency conflicts**: Resolve in build.gradle

## Best Practices

1. **Always check platform before using platform-specific code**
2. **Provide fallbacks for unsupported platforms**
3. **Use platform channels judiciously** (prefer plugins when available)
4. **Test on real devices**, not just simulators/emulators
5. **Keep native code minimal** and well-documented
6. **Version platform dependencies carefully**
7. **Handle permission requests gracefully**
8. **Respect platform design guidelines** (Material vs Cupertino)

## Final Checklist

Before deploying:
- [ ] All required permissions configured
- [ ] Platform-specific features tested on real devices
- [ ] Build configurations set up correctly
- [ ] Signing certificates valid
- [ ] Deep links tested
- [ ] Background tasks working
- [ ] Platform UI guidelines followed
- [ ] Error handling implemented
- [ ] Documentation updated

**Always prioritize platform consistency, proper native integration, and excellent user experience on both iOS and Android.**
