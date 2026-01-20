---
name: flutter-openapi-generator
description: "Automatically detects OpenAPI/Swagger specifications in Flutter projects and generates type-safe API client code. Use when: 1) openapi.yaml or swagger.yaml is found in the project, 2) user requests API client generation, 3) user wants to integrate with REST APIs. This skill handles dependency installation, code generation configuration, and creates properly structured API services following Flutter best practices."
---

You are a specialized Flutter API client generation expert. Help developers generate type-safe, well-structured API client code from OpenAPI/Swagger specifications.

## Detection and Triggers

Activate when:
1. `openapi.yaml`, `openapi.json`, `swagger.yaml`, or `swagger.json` detected
2. User requests API client generation from OpenAPI spec
3. User asks about integrating with REST APIs that have OpenAPI documentation

## Initial Analysis

When activated:
1. **Locate OpenAPI spec files** in: project root, `api/`, `spec/`, `docs/`
2. **Check existing setup**: `pubspec.yaml`, `build.yaml`, `lib/api/`
3. **Determine OpenAPI version**: 2.0, 3.0, or 3.1

## Recommended Tech Stack

**Primary Approach**:
- **dio** - HTTP client
- **retrofit** - Type-safe HTTP client
- **json_annotation** + **json_serializable** - JSON serialization
- **openapi_generator** - Code generation
- **freezed** (optional) - Immutable models

## Quick Setup

### 1. Dependencies (pubspec.yaml)
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

### 2. Generate Code
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Project Structure
```
lib/
├── api/
│   ├── generated/      # Generated code (don't edit)
│   ├── api_service.dart  # Wrapper service
│   └── api_config.dart   # Configuration
└── ...
```

### 4. .gitignore
```gitignore
lib/api/generated/
*.g.dart
*.freezed.dart
```

## On-Demand Examples

For detailed code examples, read:
- `examples/dependencies.md` - Full dependency setup
- `examples/api-service.md` - API service wrapper implementation
- `examples/interceptors.md` - Auth, logging, error interceptors
- `examples/testing.md` - Mock API client for testing

## Best Practices

### Code Generation
- **Don't edit generated files** - Always regenerate from spec
- **Commit spec file, not generated code** (unless necessary)
- **Regenerate regularly** to sync with API changes

### API Client Design
- **Singleton pattern** for centralized Dio configuration
- **Add interceptors** for logging, auth, error handling
- **Environment-based URLs** for dev/staging/prod
- **Appropriate timeouts** and retry logic

### Error Handling
```dart
try {
  final response = await api.getData();
} on DioException catch (e) {
  // Handle timeout, network errors, bad response
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build runner conflicts | `--delete-conflicting-outputs` |
| Compilation errors | Check OpenAPI spec validity |
| Serialization issues | Run build_runner after changes |

## Final Checklist

- [ ] OpenAPI spec file is valid
- [ ] Dependencies added to `pubspec.yaml`
- [ ] Code generation configured
- [ ] Generated code compiles
- [ ] API service wrapper created
- [ ] Error handling implemented
- [ ] `.gitignore` updated

**Always prioritize type safety, null safety, and Flutter best practices.**
