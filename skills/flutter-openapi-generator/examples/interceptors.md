# Dio Interceptors

## Pretty Log Interceptor

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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('✗ ${err.requestOptions.method} ${err.requestOptions.path}');
    print('Error: ${err.message}');
    super.onError(err, handler);
  }
}
```

## Authentication Interceptor with Token Refresh

```dart
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      final refreshed = await tokenStorage.refreshToken();
      if (refreshed) {
        // Retry request
        final opts = err.requestOptions;
        final token = await tokenStorage.getToken();
        opts.headers['Authorization'] = 'Bearer $token';
        final response = await Dio().fetch(opts);
        return handler.resolve(response);
      }
    }
    super.onError(err, handler);
  }
}
```

## Retry Interceptor

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
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      await Future.delayed(retryDelay * (retryCount + 1));

      final opts = err.requestOptions;
      opts.extra['retryCount'] = retryCount + 1;

      try {
        final response = await Dio().fetch(opts);
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
        (err.response?.statusCode ?? 0) >= 500;
  }
}
```

## Using Interceptors

```dart
final dio = Dio();

// Add all interceptors
dio.interceptors.addAll([
  AuthInterceptor(tokenStorage),
  RetryInterceptor(maxRetries: 3),
  PrettyLogInterceptor(),
]);
```
