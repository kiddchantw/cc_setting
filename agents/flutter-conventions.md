# Flutter Project Conventions & Best Practices

本文件定義了本專案 Flutter 與 Dart 開發的核心規範，旨在保持 UI 一致性、效能優化與代碼可維護性。

---

## 🏗️ Widget 架構規範 (Widget Architecture)

### 1. Widget 拆分原則 (Composition over Inheritance)
**原則**: 避免超大型 Widget。應將複雜的 UI 拆分為獨立、功能單一的小型 Widget。

```dart
// ❌ BAD: Massive widget with mixed concerns
class UserProfileScreen extends StatefulWidget { ... }

// ✅ GOOD: Broken down into smaller widgets
class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const UserProfileHeader(),
        const UserProfileStats(),
        const UserProfilePosts(),
      ],
    );
  }
}
```

### 2. 效能優化：Const 構造函數
**原則**: 只要 Widget 不依賴變量，應永遠使用 `const`。這能顯著減少重繪 (Rebuild) 消耗。

```dart
// ❌ BAD: Missing const
return Container(child: Text('Hello'));

// ✅ GOOD: Using const
return Container(child: const Text('Hello'));
```

### 3. List 渲染優化
**原則**: 除非清單長度極短，否則應永遠使用 `.builder`。

```dart
// ❌ BAD: Inefficient (creates all items at once)
ListView(children: items.map((e) => Item(e)).toList());

// ✅ GOOD: Efficient (lazy loading)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => Item(items[index]),
);
```

---

## 🧠 狀態管理與生命週期 (State & Lifecycle)

### 1. 資源釋放 (Proper Disposal)
**原則**: 所有的 `Controller` (Text, Animation, Scroll) 與 `Stream` 必須在 `dispose()` 中關閉，以防記憶體洩漏。

```dart
@override
void dispose() {
  controller.dispose(); // ✅ 必須釋放
  super.dispose();
}
```

### 2. State 變動
**原則**: 嚴禁在 `build` 方法內直接調用 `setState`。應確保 `setState` 只在事件處理函式中執行。

---

## 🔒 程式碼安全性 (Code Safety)

### 1. Null Safety 最佳實踐
**原則**: 優先使用 `?.` 與 `??`，盡可能避免使用 `!` 強制斷言。

```dart
// ❌ BAD: Dangerous
final name = user!.name!; 

// ✅ GOOD: Safe Handling
final name = user?.name ?? 'Guest';
```

### 2. Late 變數
**原則**: 只有在確定變數會在首次使用前初始化時才使用 `late`。

---

## ⚡ 效能檢查清單
- ✅ 是否使用了 `const` 修飾符？
- ✅ 列表是否使用了 `.builder` 模式？
- ✅ 是否避免了在 `build` 方法中執行耗時操作（如 I/O、計算）？
- ✅ 異步數據是否使用了 `FutureBuilder` 或 `StreamBuilder`？

---

## 🎨 代碼風格
- 遵循 **Effective Dart** 官方規範。
- 文件夾結構：`lib/ui/widgets/`, `lib/logic/models/`, `lib/logic/providers/`。
- 變數命名：使用 `camelCase`。
- 類別命名：使用 `PascalCase`。
