# Flutter OpenAPI Generator Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Flutter OpenAPI Generator** 是一個專門幫你從 OpenAPI/Swagger 規範**自動產生 Flutter API 客戶端程式碼**的工具。

簡單來說：
- 有 `openapi.yaml` 或 `swagger.json`？✅
- 自動生成 type-safe 的 API 服務類別！🚀
- 不用手寫 HTTP 請求程式碼！🎉

---

## 🚀 觸發指令

### 精準觸發
- `/flutter_openapi-generator`
- `使用 flutter_openapi-generator`

### 語義觸發
- "幫我從 OpenAPI 生成 API 客戶端"
- "整合這個 REST API"
- "設定 API 程式碼生成"
- "OpenAPI 轉 Dart"

### 自動觸發
- 偵測到 `openapi.yaml`, `openapi.json`
- 偵測到 `swagger.yaml`, `swagger.json`

---

## 💪 核心功能

### 1. 自動偵測 OpenAPI 規範

Skill 會搜尋以下位置：
```
your-project/
├── openapi.yaml          ✅ 專案根目錄
├── api/
│   └── openapi.yaml      ✅ api 目錄
├── spec/
│   └── swagger.json      ✅ spec 目錄
└── docs/
    └── api.yaml          ✅ docs 目錄
```

### 2. 檢查現有設定

自動分析：
- `pubspec.yaml` - 是否已安裝生成器？
- `build.yaml` - 是否已配置？
- `lib/api/` - 是否已有生成的程式碼？

### 3. 推薦技術堆疊

**主要方案（推薦）**：
| 套件 | 用途 | 為什麼需要 |
|------|------|----------|
| **dio** | HTTP 客戶端 | 強大、靈活、支援攔截器 |
| **retrofit** | Type-safe API | 自動生成類型安全的 API 呼叫 |
| **json_serializable** | JSON 序列化 | 自動處理 JSON 轉換 |
| **openapi_generator** | 程式碼生成器 | 從 OpenAPI 生成 Dart 程式碼 |
| **freezed** (可選) | 不可變模型 | 更安全的資料模型 |

---

## 📋 自動化流程

### 步驟 1: 加入依賴

Skill 會自動在 `pubspec.yaml` 加入：

```yaml
dependencies:
  dio: ^5.4.0
  json_annotation: ^4.8.1
  retrofit: ^4.0.3

dev_dependencies:
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  openapi_generator: ^4.6.2
```

### 步驟 2: 建立配置檔

自動建立 `build.yaml`：

```yaml
targets:
  $default:
    builders:
      openapi_generator|openapi_generator:
        enabled: true
        options:
          inputSpec: openapi.yaml
          generatorName: dart-dio
          output: lib/api/generated/
          additionalProperties:
            nullableFields: true
            supportDart3: true
```

### 步驟 3: 執行程式碼生成

自動執行：
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 步驟 4: 建立 API Service

自動產生 `lib/api/api_service.dart`：

```dart
import 'package:dio/dio.dart';
import 'generated/api.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // 提供 API 端點
  UsersApi get users => UsersApi(_dio);
  ProductsApi get products => ProductsApi(_dio);

  // 設定認證 token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
}
```

### 步驟 5: 整理專案結構

自動建立標準結構：

```
lib/
├── api/
│   ├── generated/              # 自動生成（不要手動編輯！）
│   │   ├── api/
│   │   │   ├── users_api.dart
│   │   │   └── products_api.dart
│   │   ├── model/
│   │   │   ├── user.dart
│   │   │   └── product.dart
│   │   └── api_client.dart
│   ├── api_service.dart        # API 服務包裝器
│   └── api_config.dart         # 配置檔
└── services/                   # 商業邏輯層
```

---

## 🎮 使用範例

### 範例 1: 獲取使用者列表

```dart
Future<void> fetchUsers() async {
  try {
    final response = await ApiService().users.getUsers();
    final users = response.data;
    print('獲取了 ${users.length} 位使用者');

    for (var user in users) {
      print('${user.name} (${user.email})');
    }
  } catch (e) {
    print('錯誤：$e');
  }
}
```

### 範例 2: 建立新使用者（含錯誤處理）

```dart
Future<User?> createUser(String name, String email) async {
  try {
    final request = CreateUserRequest(
      name: name,
      email: email,
    );

    final response = await ApiService().users.createUser(request);
    print('使用者建立成功！ID: ${response.data.id}');
    return response.data;

  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      print('驗證錯誤：${e.response?.data}');
    } else if (e.response?.statusCode == 401) {
      print('未授權，請先登入');
    } else {
      print('網路錯誤：${e.message}');
    }
    return null;
  }
}
```

### 範例 3: 帶認證的請求

```dart
// 登入後設定 token
void login(String token) {
  ApiService().setAuthToken(token);
}

// 之後的所有請求都會自動帶上 token
Future<void> fetchMyProfile() async {
  final response = await ApiService().users.getMyProfile();
  print('歡迎，${response.data.name}！');
}

// 登出時清除 token
void logout() {
  ApiService().clearAuthToken();
}
```

### 範例 4: 上傳檔案

```dart
Future<void> uploadAvatar(File imageFile) async {
  try {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar.jpg',
      ),
    });

    final response = await ApiService().users.uploadAvatar(formData);
    print('頭像上傳成功！URL: ${response.data.avatarUrl}');
  } catch (e) {
    print('上傳失敗：$e');
  }
}
```

---

## 🛠️ 進階功能

### 1. 環境切換（開發/測試/正式）

```dart
// lib/api/api_config.dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}

// 使用時指定環境
// flutter run --dart-define=API_BASE_URL=https://dev.example.com   # 開發
// flutter run --dart-define=API_BASE_URL=https://staging.example.com  # 測試
// flutter run  # 預設正式環境
```

### 2. 請求/回應日誌

```dart
class PrettyLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('→ ${options.method} ${options.path}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('← ${response.statusCode} ${response.requestOptions.path}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }
}

// 加入到 Dio
_dio.interceptors.add(PrettyLogInterceptor());
```

### 3. 自動重試機制

```dart
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] < maxRetries) {
      err.requestOptions.extra['retryCount'] =
          (err.requestOptions.extra['retryCount'] ?? 0) + 1;

      await Future.delayed(retryDelay);

      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}
```

### 4. Token 自動刷新

```dart
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token 過期，嘗試刷新
      final refreshed = await tokenStorage.refreshToken();

      if (refreshed) {
        // 重新發送請求
        final opts = err.requestOptions;
        final token = await tokenStorage.getToken();
        opts.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await Dio().fetch(opts);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }
    super.onError(err, handler);
  }
}
```

---

## ✅ 最佳實踐

### 1. 不要手動編輯生成的程式碼
```
❌ 不好：直接修改 lib/api/generated/ 下的檔案
✅ 好：修改 openapi.yaml 後重新生成
```

### 2. 版本控制

```gitignore
# .gitignore
lib/api/generated/    # 不要提交生成的程式碼（除非必要）
*.g.dart
*.freezed.dart
```

但**一定要提交**：
- ✅ `openapi.yaml` - API 規範
- ✅ `build.yaml` - 生成配置
- ✅ `pubspec.yaml` - 依賴

### 3. 定期重新生成

API 規範更新後：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. 統一錯誤處理

```dart
// lib/api/api_error.dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

// 使用
try {
  final response = await api.getData();
  return response.data;
} on DioException catch (e) {
  switch (e.response?.statusCode) {
    case 400:
      throw ApiException(400, '請求參數錯誤');
    case 401:
      throw ApiException(401, '未授權，請重新登入');
    case 404:
      throw ApiException(404, '資源不存在');
    case 500:
      throw ApiException(500, '伺服器錯誤');
    default:
      throw ApiException(null, '網路錯誤：${e.message}');
  }
}
```

### 5. 使用環境變數

```dart
// 不要寫死 API URL
❌ baseUrl: 'https://api.example.com'

// 使用環境變數
✅ baseUrl: const String.fromEnvironment('API_BASE_URL')
```

---

## 🧪 測試

### 使用 Mock 測試

```dart
// test/mocks/mock_api.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UsersApi])
void main() {}

// test/api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_api.mocks.dart';

void main() {
  test('fetch users returns list', () async {
    // 建立 mock
    final mockApi = MockUsersApi();

    // 設定行為
    when(mockApi.getUsers()).thenAnswer(
      (_) async => Response(
        data: [
          User(id: 1, name: '測試使用者'),
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/users'),
      ),
    );

    // 執行測試
    final users = await mockApi.getUsers();

    // 驗證結果
    expect(users.data?.length, 1);
    expect(users.data?.first.name, '測試使用者');
  });
}
```

---

## 🐛 常見問題

### 問題 1: Build runner 失敗

**錯誤訊息**：
```
Conflicting outputs were detected...
```

**解決方法**：
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 問題 2: 生成的程式碼有編譯錯誤

**可能原因**：
- OpenAPI 規範格式不正確
- 套件版本不相容
- Null safety 設定問題

**解決方法**：
1. 驗證 OpenAPI 規範：https://editor.swagger.io/
2. 更新套件版本：`flutter pub upgrade`
3. 檢查 `additionalProperties` 設定

### 問題 3: JSON 序列化失敗

**錯誤訊息**：
```
type 'Null' is not a subtype of type 'String'
```

**解決方法**：
在 `build.yaml` 加入：
```yaml
additionalProperties:
  nullableFields: true  # 允許欄位為 null
```

### 問題 4: 無法連接 API

**檢查清單**：
- ✅ Base URL 是否正確？
- ✅ 是否需要 HTTPS？
- ✅ 是否需要認證 token？
- ✅ 網路權限是否設定？（Android 需要在 AndroidManifest.xml 加入）

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
```

---

## 📚 完整範例專案

假設你的 `openapi.yaml` 定義了這些端點：
- `GET /users` - 獲取使用者列表
- `POST /users` - 建立使用者
- `GET /users/{id}` - 獲取單一使用者

生成後的使用方式：

```dart
// lib/screens/users_screen.dart
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/generated/model/models.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService().users.getUsers();
      setState(() {
        _users = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createUser() async {
    final request = CreateUserRequest(
      name: 'New User',
      email: 'user@example.com',
    );

    try {
      await ApiService().users.createUser(request);
      _loadUsers(); // 重新載入列表
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('建立失敗：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('使用者列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('錯誤：$_error'))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(user.name ?? ''),
                      subtitle: Text(user.email ?? ''),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // 導航到使用者詳情頁面
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🎯 總結

**Flutter OpenAPI Generator Skill** 幫你：

- 🤖 **自動偵測** OpenAPI 規範檔案
- 📦 **自動安裝** 所有必要套件
- ⚙️ **自動配置** 程式碼生成器
- 🚀 **自動生成** type-safe API 客戶端
- 📁 **自動整理** 專案結構
- 💡 **提供範例** 使用方式和最佳實踐

**讓 API 整合變得超級簡單！** 🎉

---

**相關檔案**：
- Skill 定義：`skills/flutter_openapi-generator/SKILL.md`
- Agent 定義：`agents/flutter-expert.md`
