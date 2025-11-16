# Flutter Platform Integration Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Flutter Platform Integration** 是一個專門處理 Flutter **雙平台（iOS/Android）整合和原生功能**的工具。

簡單來說：
- 幫你整合原生功能（相機、位置、推播等）🔧
- 設定 iOS/Android 平台配置 ⚙️
- 實作 Platform Channels 通訊 🌉
- 適配雙平台 UI/UX 設計 🎨

---

## 🚀 自動觸發條件

這個 skill 會在以下情況**自動啟動**：

### 平台特定需求
- "新增 iOS 權限"
- "設定 AndroidManifest"
- "實作 Platform Channel"
- "整合原生程式碼"
- "雙平台 UI 適配"
- "add iOS permission"
- "implement platform channel"
- "configure Android"

### 使用場景
- 實作 Method/Event Channels
- 配置平台特定設定（Info.plist、AndroidManifest.xml）
- 整合原生程式碼（Swift、Kotlin、Objective-C、Java）
- 設定平台權限和功能
- 處理平台特定功能（相機、位置、通知等）
- 適配 iOS 和 Android UI 設計語言
- 排除平台 build 或部署問題
- 建立 Flutter plugins

---

## 🔧 核心功能

### 1. 平台配置

#### iOS 配置

**Info.plist 設定**：

```xml
<!-- 相機權限 -->
<key>NSCameraUsageDescription</key>
<string>此 App 需要相機權限來掃描 QR Code</string>

<!-- 位置權限 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>此 App 需要位置資訊來顯示附近的商店</string>

<!-- 相簿權限 -->
<key>NSPhotoLibraryUsageDescription</key>
<string>此 App 需要相簿權限來上傳圖片</string>

<!-- 麥克風權限 -->
<key>NSMicrophoneUsageDescription</key>
<string>此 App 需要麥克風權限來錄音</string>
```

**Podfile 設定**：

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # 新增自訂 pods（如需要）
  pod 'Firebase/Analytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

#### Android 配置

**AndroidManifest.xml 設定**：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 權限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <!-- 功能 -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />

    <application
        android:label="我的 App"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Deep Links -->
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

**build.gradle 設定**：

```gradle
// app/build.gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.myapp"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
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
```

---

### 2. Platform Channels 實作

#### Method Channels（方法呼叫）

**Flutter 端**：

```dart
import 'package:flutter/services.dart';

class PlatformService {
  static const platform = MethodChannel('com.example.app/platform');

  // 呼叫平台方法
  Future<String> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return '電量：$result%';
    } on PlatformException catch (e) {
      return '無法取得電量：${e.message}';
    }
  }

  // 帶參數呼叫
  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'getUserData',
        {'userId': userId},
      );
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('失敗：${e.message}');
    }
  }
}
```

**iOS 端（Swift）**：

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
            "name": "王小明",
            "email": "wang@example.com"
        ]
        result(userData)
    }
}
```

**Android 端（Kotlin）**：

```kotlin
package com.example.myapp

import android.os.BatteryManager
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
                        result.error("UNAVAILABLE", "無法取得電量", null)
                    }
                }
                "getUserData" -> {
                    val userId = call.argument<String>("userId")
                    if (userId != null) {
                        val userData = getUserData(userId)
                        result.success(userData)
                    } else {
                        result.error("INVALID_ARGUMENT", "需要 userId", null)
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
            "name" to "王小明",
            "email" to "wang@example.com"
        )
    }
}
```

#### Event Channels（事件串流）

**用於持續接收原生事件**（如感應器資料、位置更新等）

**Flutter 端**：

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

// 使用
SensorService().accelerometerEvents.listen((data) {
  print('加速度計：$data');
});
```

---

### 3. 雙平台 UI 適配

#### 適應性 Widgets

```dart
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 平台自適應按鈕
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

// 平台自適應對話框
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
            child: const Text('確定'),
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
          child: const Text('確定'),
        ),
      ],
    ),
  );
}

// 平台自適應 Loading 指示器
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

// 平台自適應開關
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

---

### 4. 權限處理

```dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 請求單一權限
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
      // 開啟 App 設定
      await openAppSettings();
      return false;
    }

    return false;
  }

  // 請求多個權限
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  // 檢查所有權限是否都已授予
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

// 使用範例
Future<void> takePicture() async {
  final hasPermission = await PermissionService.requestPermission(
    Permission.camera,
  );

  if (hasPermission) {
    // 開啟相機
    print('相機權限已授予');
  } else {
    // 顯示權限被拒絕的訊息
    print('相機權限被拒絕');
  }
}

// 請求多個權限
Future<void> requestLocationAndCamera() async {
  final statuses = await PermissionService.requestMultiplePermissions([
    Permission.camera,
    Permission.location,
  ]);

  if (statuses[Permission.camera]!.isGranted &&
      statuses[Permission.location]!.isGranted) {
    print('所有權限已授予');
  }
}
```

---

### 5. Build 配置

#### iOS Build

**建置指令**：

```bash
# 建置 iOS app
flutter build ios --release

# 建置並指定 bundle ID
flutter build ios --release --bundle-id com.example.myapp

# 建置 IPA（用於上架）
flutter build ipa --export-options-plist=ExportOptions.plist
```

**程式碼簽署**：

1. 在 Xcode 中開啟 `ios/Runner.xcworkspace`
2. 選擇 Runner → Signing & Capabilities
3. 選擇你的開發團隊
4. 確認 Bundle Identifier 正確

#### Android Build

**建置指令**：

```bash
# 建置 Android APK
flutter build apk --release

# 建置 Android App Bundle（上架 Play Store 用）
flutter build appbundle --release

# 建置分離 APK（每個 CPU 架構一個）
flutter build apk --split-per-abi
```

**簽署設定**：

1. 產生 keystore：
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. 建立 `android/key.properties`：
```properties
storePassword=你的密碼
keyPassword=你的密碼
keyAlias=upload
storeFile=/Users/你的使用者名稱/upload-keystore.jks
```

3. 在 `android/app/build.gradle` 加入：
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

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
        }
    }
}
```

---

### 6. Deep Linking（深層連結）

**Flutter 配置**：

```dart
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class DeepLinkService {
  StreamSubscription? _sub;

  Future<void> init() async {
    // 處理初始連結（App 未執行時）
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e) {
      print('處理初始連結錯誤：$e');
    }

    // 監聽連結更新（App 執行中）
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(link);
      }
    });
  }

  void _handleLink(String link) {
    print('收到深層連結：$link');
    final uri = Uri.parse(link);

    // 根據 uri 進行導航
    if (uri.path == '/product') {
      final productId = uri.queryParameters['id'];
      // 導航到產品頁面
      print('開啟產品：$productId');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
```

**iOS 設定** (Info.plist)：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

**Android 設定** (AndroidManifest.xml)：

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- myapp://example.com/product?id=123 -->
    <data android:scheme="myapp" android:host="example.com" />
</intent-filter>
```

---

## 🧪 測試平台特定程式碼

### 模擬 Platform Channels

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

  test('getBatteryLevel 回傳電量', () async {
    final result = await channel.invokeMethod('getBatteryLevel');
    expect(result, 85);
  });
}
```

---

## 🐛 常見問題

### iOS 問題

**1. Pods 找不到**
```bash
cd ios
pod install
```

**2. 簽署錯誤**
- 檢查 Xcode 中的 Signing & Capabilities
- 確認憑證和 provisioning profile 有效

**3. Info.plist 缺少權限說明**
- 加入對應的權限描述（NSCameraUsageDescription 等）

**4. Build 失敗**
```bash
flutter clean
cd ios
pod deintegrate
pod install
```

### Android 問題

**1. Gradle build 失敗**
- 檢查 Gradle 版本相容性
- 更新 `android/gradle/wrapper/gradle-wrapper.properties`

**2. 需要啟用 MultiDex**
```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

**3. 權限被拒絕**
- 確認 AndroidManifest.xml 中有宣告權限
- 在程式碼中請求執行時權限

**4. 依賴衝突**
```bash
cd android
./gradlew app:dependencies
# 檢查依賴樹，解決版本衝突
```

---

## ✅ 最佳實踐

1. **平台判斷**
   ```dart
   // ✅ 好
   if (Platform.isIOS) {
     // iOS 特定邏輯
   }

   // ❌ 不好：假設只有兩個平台
   if (Platform.isIOS) {
     // iOS
   } else {
     // 假設是 Android，但可能是其他平台
   }
   ```

2. **提供 Fallback**
   ```dart
   Future<String> getPlatformVersion() async {
     try {
       return await platform.invokeMethod('getVersion');
     } catch (e) {
       return 'Unknown'; // 提供預設值
     }
   }
   ```

3. **在真實裝置上測試**
   - 模擬器無法完全模擬真實環境
   - 感應器、相機等功能必須在真機測試

4. **保持原生程式碼簡潔**
   - 優先使用現有的 Flutter plugins
   - 只在必要時才寫原生程式碼

5. **尊重平台設計規範**
   - iOS 使用 Cupertino widgets
   - Android 使用 Material widgets
   - 或使用自適應 widgets

6. **版本控制注意事項**
   ```gitignore
   # .gitignore
   **/android/key.properties
   **/ios/Runner.xcworkspace/
   **/ios/Pods/
   ```

---

## 📋 部署前檢查清單

- [ ] 所有必要權限已配置（Info.plist、AndroidManifest.xml）
- [ ] 平台特定功能在真實裝置上測試過
- [ ] Build 配置正確設定
- [ ] 簽署憑證有效
- [ ] Deep Links 測試通過
- [ ] 背景任務正常運作
- [ ] 遵循平台 UI 設計規範
- [ ] 錯誤處理已實作
- [ ] 文件已更新

---

## 💡 總結

**Flutter Platform Integration Skill** 幫你：

- 🔧 **無縫整合** - 輕鬆串接 iOS/Android 原生功能
- 🌉 **Platform Channels** - 完整的雙向通訊範例
- ⚙️ **配置指導** - 詳細的平台設定教學
- 🎨 **UI 適配** - Material 和 Cupertino 完美融合
- 📱 **真實測試** - 在真實裝置上驗證功能
- ✅ **最佳實踐** - 遵循平台設計規範

**讓你的 Flutter App 在 iOS 和 Android 都完美運行！** 🚀🎉

---

**相關檔案**：
- Skill 定義：`skills/flutter-platform-integration/SKILL.md`
- Agent 定義：`agents/flutter-expert.md`
- Flutter Expert 繁中指南：`README_flutter-expert_zh_TW.md`
