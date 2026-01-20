# API Service Wrapper

## lib/api/api_service.dart

```dart
import 'package:dio/dio.dart';
import 'generated/api.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final ApiClient _apiClient;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    _apiClient = ApiClient(dio: _dio);
  }

  // Expose API endpoints
  UsersApi get users => UsersApi(_dio);
  ProductsApi get products => ProductsApi(_dio);

  // Add authentication
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
```

## lib/api/api_config.dart

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}

// Usage: flutter run --dart-define=API_BASE_URL=https://staging.example.com
```

## Usage Examples

```dart
// Example 1: Fetch users
Future<void> fetchUsers() async {
  try {
    final response = await ApiService().users.getUsers();
    final users = response.data;
    print('Fetched ${users.length} users');
  } catch (e) {
    print('Error fetching users: $e');
  }
}

// Example 2: Create user with error handling
Future<User?> createUser(CreateUserRequest request) async {
  try {
    final response = await ApiService().users.createUser(request);
    return response.data;
  } on DioException catch (e) {
    if (e.response?.statusCode == 400) {
      print('Validation error: ${e.response?.data}');
    } else if (e.response?.statusCode == 401) {
      print('Unauthorized');
    }
    return null;
  }
}

// Example 3: With authentication
void login(String token) {
  ApiService().setAuthToken(token);
}
```

## Error Handling Pattern

```dart
try {
  final response = await api.getData();
  return response.data;
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      throw TimeoutException('Request timeout');
    case DioExceptionType.badResponse:
      throw ApiException(e.response?.statusCode, e.response?.data);
    default:
      throw NetworkException('Network error');
  }
}
```
