# Platform Channels Examples

## Method Channel

### Flutter Side
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

### iOS Side (Swift)
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
        let userData: [String: Any] = [
            "id": userId,
            "name": "John Doe",
            "email": "john@example.com"
        ]
        result(userData)
    }
}
```

### Android Side (Kotlin)
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

## Event Channel

### Flutter Side
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

### iOS Side (Swift)
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

## Testing Platform Channels

```dart
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
