# Dependencies Setup

## Full pubspec.yaml Configuration

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
  # Optional but recommended
  freezed: ^2.4.6
  freezed_annotation: ^2.4.1
```

## build.yaml Configuration

```yaml
targets:
  $default:
    builders:
      openapi_generator|openapi_generator:
        enabled: true
        options:
          inputSpec: openapi.yaml  # or path to your spec file
          generatorName: dart-dio
          output: lib/api/generated/
          additionalProperties:
            pubName: ${project_name}_api
            pubAuthor: Your Name
            pubDescription: API Client
            nullableFields: true
            supportDart3: true
```

## Alternative: openapi-generator-config.yaml

```yaml
generator-name: dart-dio
input-spec: openapi.yaml
output-dir: lib/api/generated
additional-properties:
  pubName: api_client
  nullableFields: true
  supportDart3: true
  useEnumExtension: true
  enumUnknownDefaultCase: true
```

## Generation Commands

```bash
# Using build_runner
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Or using openapi-generator-cli
# First install: npm install -g @openapitools/openapi-generator-cli
openapi-generator-cli generate -i openapi.yaml -g dart-dio -o lib/api/generated
```
