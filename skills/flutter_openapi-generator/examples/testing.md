# Testing API Clients

## Generate Mock Clients

```dart
// test/mocks/mock_api.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/api/generated/api.dart';

@GenerateMocks([UsersApi, ProductsApi])
void main() {}
```

Run: `flutter pub run build_runner build`

## Example Tests

```dart
// test/api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'mocks/mock_api.mocks.dart';

void main() {
  late MockUsersApi mockUsersApi;

  setUp(() {
    mockUsersApi = MockUsersApi();
  });

  group('UsersApi', () {
    test('getUsers returns list of users', () async {
      // Arrange
      when(mockUsersApi.getUsers()).thenAnswer(
        (_) async => Response(
          data: [
            User(id: 1, name: 'Test User', email: 'test@example.com'),
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/users'),
        ),
      );

      // Act
      final response = await mockUsersApi.getUsers();

      // Assert
      expect(response.data?.length, 1);
      expect(response.data?.first.name, 'Test User');
      verify(mockUsersApi.getUsers()).called(1);
    });

    test('createUser handles validation error', () async {
      // Arrange
      when(mockUsersApi.createUser(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users'),
          response: Response(
            statusCode: 400,
            data: {'message': 'Email is required'},
            requestOptions: RequestOptions(path: '/users'),
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      // Act & Assert
      expect(
        () => mockUsersApi.createUser(CreateUserRequest(name: 'Test')),
        throwsA(isA<DioException>()),
      );
    });

    test('handles network timeout', () async {
      // Arrange
      when(mockUsersApi.getUsers()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/users'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      // Act & Assert
      expect(
        () => mockUsersApi.getUsers(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

## Integration Test with Mock Server

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://api.example.com'));
    dioAdapter = DioAdapter(dio: dio);
  });

  test('fetches users from mock server', () async {
    // Setup mock response
    dioAdapter.onGet(
      '/users',
      (server) => server.reply(200, [
        {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
      ]),
    );

    // Make request
    final response = await dio.get('/users');

    // Verify
    expect(response.statusCode, 200);
    expect(response.data.length, 1);
    expect(response.data[0]['name'], 'John Doe');
  });
}
```

## Testing Best Practices

1. **Mock at the API layer**, not HTTP layer when possible
2. **Test error scenarios** (timeout, 4xx, 5xx)
3. **Verify request parameters** are correct
4. **Test token refresh** flow
5. **Use dependency injection** for easier mocking
