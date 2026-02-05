# Flutter Security Review Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Flutter Security Review** 是一個專門審查 Flutter/Dart 應用程式**安全性漏洞和最佳實踐**的工具。

簡單來說：
- 幫你找出潛在的安全漏洞 🔍
- 檢查資料保護機制 🔒
- 驗證認證授權邏輯 ✅
- 確保符合安全標準 🛡️

---

## 🚀 觸發指令

### 精準觸發
- `/flutter_security-review`
- `使用 flutter_security-review`

### 語義觸發
- "檢查這段程式碼的安全性"
- "審查權限處理"
- "驗證資料保護"
- "檢查 Flutter 安全漏洞"
- "審查認證邏輯"

### 自動觸發
- 偵測到敏感資料處理（Token, Password）
- 偵測到不安全的網路請求（HTTP）
- 偵測到硬編碼的金鑰

---

## 🔍 安全檢查清單

### 1. 輸入驗證與資料清理

**檢查項目**：
- ✅ 驗證並清理所有使用者輸入
- ✅ 實作適當的表單驗證
- ✅ 檢查文字欄位的注入漏洞
- ✅ 在發送到後端 API 之前驗證資料

**範例**：

```dart
// ❌ 不安全：沒有驗證
Future<void> searchUser(String query) async {
  final url = 'https://api.example.com/search?q=$query';
  await http.get(Uri.parse(url));
}

// ✅ 安全：適當的驗證和編碼
Future<void> searchUser(String query) async {
  // 驗證輸入
  if (query.isEmpty || query.length > 100) {
    throw ArgumentError('Invalid query');
  }

  // 使用 Uri 自動編碼參數
  final uri = Uri.https('api.example.com', '/search', {'q': query});
  await http.get(uri);
}
```

### 2. 資料儲存與保護

**檢查項目**：
- ✅ 使用 `flutter_secure_storage` 或平台 keychain 安全儲存敏感資料
- ✅ 絕不在 SharedPreferences 或純文字中儲存敏感資料
- ✅ 對本地資料庫實作適當的加密（sqflite_sqlcipher）
- ✅ 不再需要時從記憶體中清除敏感資料

**範例**：

```dart
// ❌ 不安全：在 SharedPreferences 儲存 token
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// ✅ 安全：使用 flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);

// 讀取
final token = await storage.read(key: 'auth_token');

// 刪除
await storage.delete(key: 'auth_token');
```

### 3. 認證與授權

**檢查項目**：
- ✅ 實作適當的認證 token 管理
- ✅ 使用安全的 token 儲存（flutter_secure_storage）
- ✅ 實作 token 刷新機制
- ✅ 優雅地處理認證過期
- ✅ 處理敏感資料時實作生物辨識認證
- ✅ 使用 OAuth 2.0 或類似的業界標準認證

**範例**：

```dart
class AuthService {
  final _storage = FlutterSecureStorage();

  // ✅ 安全的 token 管理
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  // ✅ Token 刷新機制
  Future<String?> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/refresh'),
        body: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['access_token']);
        return data['access_token'];
      }
    } catch (e) {
      await logout();
    }
    return null;
  }
}
```

### 4. 網路安全

**檢查項目**：
- ✅ 所有網路請求使用 HTTPS
- ✅ 對敏感應用程式實作憑證釘選（Certificate Pinning）
- ✅ 適當驗證 SSL 憑證
- ✅ 避免在程式碼中暴露 API 金鑰或密鑰（使用環境變數或建置配置）
- ✅ 實作適當的錯誤處理，不洩漏敏感資訊

**範例**：

```dart
// ✅ HTTPS 和憑證釘選
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

class SecureHttpClient {
  late Dio _dio;

  SecureHttpClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com', // 使用 HTTPS
      connectTimeout: Duration(seconds: 30),
    ));

    // 憑證釘選（Certificate Pinning）
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (client) {
        client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
            // 驗證憑證指紋
            final expectedFingerprint = 'YOUR_CERT_FINGERPRINT';
            final certFingerprint = sha256.convert(cert.der).toString();
            return certFingerprint == expectedFingerprint;
          };
        return client;
      };
  }
}

// ✅ 使用環境變數隱藏 API 金鑰
class ApiConfig {
  static const apiKey = String.fromEnvironment('API_KEY');

  // 使用：flutter run --dart-define=API_KEY=your_api_key
}
```

### 5. 權限與平台安全

**檢查項目**：
- ✅ 在 iOS 和 Android 上正確處理權限
- ✅ 請求最少必要權限
- ✅ 向使用者說明權限用途
- ✅ 優雅地處理權限拒絕
- ✅ 在存取受保護資源之前檢查權限

**範例**：

```dart
import 'package:permission_handler/permission_handler.dart';

// ✅ 適當的權限處理
Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  }

  if (status.isDenied) {
    // 向使用者說明為何需要此權限
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要相機權限'),
        content: Text('此功能需要相機權限才能掃描 QR Code'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('授予權限'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newStatus = await Permission.camera.request();
      return newStatus.isGranted;
    }
  }

  if (status.isPermanentlyDenied) {
    // 引導使用者到設定頁面
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要權限'),
        content: Text('請在設定中授予相機權限'),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text('前往設定'),
          ),
        ],
      ),
    );
  }

  return false;
}
```

### 6. Deep Links 與導航

**檢查項目**：
- ✅ 驗證 deep links 和導航參數
- ✅ 在 deep link 路由上實作認證檢查
- ✅ 清理 URL 參數
- ✅ 防止未經授權導航到敏感畫面

**範例**：

```dart
// ✅ 安全的 Deep Link 處理
class DeepLinkHandler {
  Future<void> handleDeepLink(Uri uri) async {
    // 驗證來源
    if (!_isValidScheme(uri.scheme)) {
      throw SecurityException('Invalid URI scheme');
    }

    // 清理參數
    final userId = _sanitizeParameter(uri.queryParameters['user_id']);

    // 檢查認證
    if (!await _isAuthenticated()) {
      // 重導到登入頁面
      Navigator.pushNamed(context, '/login', arguments: {
        'redirect': uri.toString(),
      });
      return;
    }

    // 安全地導航
    Navigator.pushNamed(context, '/profile', arguments: {
      'userId': userId,
    });
  }

  bool _isValidScheme(String scheme) {
    return scheme == 'myapp' || scheme == 'https';
  }

  String? _sanitizeParameter(String? param) {
    if (param == null || param.isEmpty) return null;
    // 移除潛在危險字元
    return param.replaceAll(RegExp(r'[^\w\-]'), '');
  }
}
```

### 7. 程式碼安全

**檢查項目**：
- ✅ 為生產建置混淆程式碼（`--obfuscate --split-debug-info`）
- ✅ 在生產環境中移除除錯程式碼和日誌
- ✅ 避免硬編碼密鑰、API 金鑰或敏感資料
- ✅ 使用環境變數進行配置
- ✅ 實作適當的錯誤處理，不暴露堆疊追蹤

**範例**：

```bash
# ✅ 生產建置時混淆程式碼
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols

flutter build ios --obfuscate --split-debug-info=build/ios/symbols
```

```dart
// ✅ 條件式日誌
import 'package:flutter/foundation.dart';

void logDebug(String message) {
  if (kDebugMode) {
    print('[DEBUG] $message');
  }
}

// ✅ 安全的錯誤處理
try {
  await sensitiveOperation();
} catch (e) {
  if (kDebugMode) {
    print('Error details: $e'); // 僅在開發環境顯示
  }
  // 生產環境顯示友善訊息
  showErrorDialog('操作失敗，請稍後再試');
}
```

---

## 🛡️ 常見安全漏洞

### 1. 不安全的資料儲存

**症狀**：敏感資料儲存在 SharedPreferences 或純文字檔案

**解決方案**：
```dart
// ❌ 不安全
SharedPreferences.getInstance().then((prefs) {
  prefs.setString('password', userPassword);
});

// ✅ 安全
final storage = FlutterSecureStorage();
await storage.write(key: 'password', value: userPassword);
```

### 2. 傳輸層保護不足

**症狀**：使用 HTTP 而非 HTTPS

**解決方案**：
```dart
// ❌ 不安全
final response = await http.get(Uri.parse('http://api.example.com/data'));

// ✅ 安全
final response = await http.get(Uri.parse('https://api.example.com/data'));
```

### 3. 不安全的認證

**症狀**：Token 處理、Session 管理不當

**解決方案**：使用 flutter_secure_storage + 實作 token 刷新機制

### 4. 平台使用不當

**症狀**：權限使用、平台 API 審查不當

**解決方案**：實作適當的權限請求和處理邏輯

### 5. 程式碼品質問題

**症狀**：硬編碼密鑰、除錯程式碼留在生產環境

**解決方案**：使用環境變數 + 移除除錯程式碼

---

## ✅ 安全測試建議

### 測試檢查清單
- ✅ 使用不同的使用者角色和權限進行測試
- ✅ 嘗試 SQL 注入和 XSS 攻擊（如適用）
- ✅ 測試認證繞過情境
- ✅ 檢查日誌中的敏感資料
- ✅ 驗證加密儲存
- ✅ 使用代理工具（Charles、Burp Suite）測試網路請求
- ✅ 審查應用程式在 Root/越獄裝置上的行為

### 工具推薦
- **Charles Proxy** - 攔截和檢查網路請求
- **Burp Suite** - 滲透測試工具
- **Flutter DevTools** - 檢查記憶體洩漏和效能
- **MobSF** - Mobile Security Framework（自動化安全測試）

---

## 📱 平台特定考量

### Android
- ✅ 使用 ProGuard/R8 進行程式碼混淆
- ✅ 必要時實作 Root 偵測
- ✅ 安全使用 Android Keystore
- ✅ 驗證應用程式簽署憑證

**範例**：

```groovy
// android/app/build.gradle
android {
    buildTypes {
        release {
            // 啟用 R8 混淆
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### iOS
- ✅ 使用 Keychain 儲存敏感資料
- ✅ 必要時實作越獄偵測
- ✅ 遵循 iOS 安全指南
- ✅ 使用 App Transport Security (ATS)

**範例**：

```xml
<!-- ios/Runner/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

## 🎯 安全審查流程

### 步驟 1: 輸入驗證檢查
檢查所有使用者輸入點，確保適當的驗證和清理。

### 步驟 2: 資料保護審查
確認敏感資料使用安全儲存機制。

### 步驟 3: 認證授權檢查
驗證 token 管理、session 處理和存取控制。

### 步驟 4: 網路安全審查
確保所有請求使用 HTTPS，敏感 app 實作憑證釘選。

### 步驟 5: 程式碼品質檢查
尋找硬編碼密鑰、除錯程式碼和安全隱患。

### 步驟 6: 平台安全驗證
檢查權限處理和平台特定安全設定。

---

## 📚 相關資源

### 官方文件
- [OWASP Mobile Security Testing Guide](https://owasp.org/www-project-mobile-security-testing-guide/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Android Security Guidelines](https://developer.android.com/privacy-and-security/security-tips)
- [iOS Security Guidelines](https://developer.apple.com/documentation/security)

### 推薦套件
- **flutter_secure_storage** - 安全儲存敏感資料
- **permission_handler** - 權限管理
- **local_auth** - 生物辨識認證
- **dio** - 支援攔截器的 HTTP 客戶端
- **sqflite_sqlcipher** - 加密的 SQLite 資料庫

---

## 💡 總結

**Flutter Security Review Skill** 幫你：

- 🔍 **全面檢查** - 涵蓋所有關鍵安全領域
- 🛡️ **預防漏洞** - 在部署前發現問題
- ✅ **最佳實踐** - 確保符合業界標準
- 📋 **清單驅動** - 系統化的安全審查流程
- 🔒 **資料保護** - 確保敏感資料安全
- 🚀 **生產就緒** - 讓你的 app 安全上線

**讓你的 Flutter 應用更安全、更可靠！** 🎉

---

**相關檔案**：
- Skill 定義：`skills/flutter_security-review/SKILL.md`
- Agent 定義：`agents/flutter-expert.md`
- Flutter Expert 繁中指南：`flutter-expert-zh_TW.md`
