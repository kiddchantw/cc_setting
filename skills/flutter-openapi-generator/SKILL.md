---
name: flutter-openapi-generator
description: "Automatically detects OpenAPI/Swagger specifications in Flutter projects and generates type-safe API client code. Use when: 1) openapi.yaml or swagger.yaml is found in the project, 2) user requests API client generation, 3) user wants to integrate with REST APIs."
---

## 用途

從 `openapi.yaml` 生成 Flutter (dart-dio) API client。

## 已知問題

`build_runner` 內嵌的 `openapi_generator` dart 包在遇到 spec 驗證錯誤時，會**靜默跳過部分 endpoint** 而不報錯。
因此本 skill **必須使用 CLI 版本** `openapi-generator`（Homebrew 安裝）來生成。

## 流程（三步）

### Step 1：確保 openapi.yaml 是最新的

如果專案同時有 Laravel 與 Flutter：

```bash
# 在 Docker 內重新產生 Laravel spec（遵守 Docker 規範）
docker-compose -f ../../laradock/docker-compose.yml exec \
  -w /var/www/a126/A126-kompraa_web workspace \
  php artisan scribe:generate --force

# 複製到 Flutter 專案
cp A126-kompraa_web/public/docs/openapi.yaml a126_kompraa_flutter/openapi.yaml
```

### Step 2：用 CLI 生成 api_client

```bash
cd a126_kompraa_flutter

openapi-generator generate \
  -o api_client \
  -i openapi.yaml \
  -g dart-dio \
  --additional-properties=pubName=a126_api_client,pubAuthor="A126 Team" \
  --skip-validate-spec
```

> **不要用** `flutter pub run build_runner build` 來觸發 openapi_generator。
> build_runner 版本會靜默跳過有問題的 endpoint。

### Step 3：生成 serializer (.g.dart)

```bash
cd api_client
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 驗證

生成完後快速確認目標 endpoint 有產出：

```bash
# 確認 API class 存在
ls api_client/lib/src/api/ | grep -i <target>

# 確認 model 存在
ls api_client/lib/src/model/ | grep -i <target>
```

找不到 → 生成失敗，不要繼續往下做 service/provider。

## 注意事項

- PHP / Composer / Artisan 指令必須在 Docker 容器內執行（見 `.cursorrules`）
- `--skip-validate-spec` 是必要的，因為 spec 可能有 Scribe 產生的非致命驗證問題（如 duplicate operationId）
- 如果新 endpoint 在 spec 裡找不到，先檢查 Laravel Controller 的 Scribe 註解是否完整（需要 `@response 200` 帶 schema）
