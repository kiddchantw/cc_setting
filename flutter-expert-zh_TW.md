# Flutter Expert Agent 使用指南

## 🎯 這個 Agent 是什麼？

**Flutter Expert** 是一個專門為 Flutter 開發設計的 AI 助手，就像你身邊有一位資深的 Flutter 技術顧問，隨時幫你寫程式、優化效能、解決問題。

---

## 🚀 自動觸發條件

這個 agent 會在以下情況**自動啟動**（不用你主動呼叫）：

### 偵測到 Flutter 專案
- ✅ 發現 `.dart` 檔案
- ✅ 發現 `pubspec.yaml`
- ✅ 發現 `lib/` 目錄結構

### 使用場景範例

**場景 1：建立 UI**
```
你: "建立一個登入畫面"
（在 Flutter 專案中）
→ Flutter Expert 自動啟動，幫你實作 LoginScreen widget
```

**場景 2：程式碼審查**
```
你: 編輯一個 .dart 檔案
→ Flutter Expert 自動審查並建議改進
```

**場景 3：效能問題**
```
你: "為什麼我的 app 這麼慢？"
→ Flutter Expert 分析效能瓶頸
```

---

## 💪 核心能力

### 1. **Dart 語言精通**

掌握 Dart 所有進階功能：

```dart
// Null safety（空安全）
String? userName;  // 可為 null
String email = '';  // 不可為 null

// async/await 非同步處理
Future<User> fetchUser() async {
  final response = await http.get(Uri.parse(apiUrl));
  return User.fromJson(json.decode(response.body));
}

// Streams（串流）
Stream<int> countStream() async* {
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

// Isolates（平行處理）
Future<void> heavyComputation() async {
  final result = await compute(parseData, largeData);
}
```

### 2. **Widget 架構**

熟悉所有 Widget 類型：

```dart
// StatelessWidget - 靜態 widget
class MyText extends StatelessWidget {
  const MyText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

// StatefulWidget - 有狀態 widget
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_count');
  }
}

// InheritedWidget - 跨層級資料傳遞
class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget({
    required this.data,
    required super.child,
    super.key,
  });

  final String data;

  static MyInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MyInheritedWidget oldWidget) {
    return data != oldWidget.data;
  }
}
```

### 3. **狀態管理**

幫你選擇和實作最適合的狀態管理方案：

| 方案 | 適用場景 | 學習曲線 |
|------|---------|---------|
| **Provider** | 中小型專案，官方推薦 | ⭐⭐⭐ |
| **Riverpod** | Provider 進化版，更安全 | ⭐⭐⭐⭐ |
| **Bloc** | 大型專案，嚴謹架構 | ⭐⭐⭐⭐⭐ |
| **GetX** | 快速開發，輕量級 | ⭐⭐ |
| **MobX** | 響應式程式設計 | ⭐⭐⭐⭐ |

**範例：Provider**
```dart
// 1. 定義狀態
class CounterProvider extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

// 2. 提供狀態
ChangeNotifierProvider(
  create: (_) => CounterProvider(),
  child: MyApp(),
);

// 3. 使用狀態
Consumer<CounterProvider>(
  builder: (context, counter, child) {
    return Text('${counter.count}');
  },
);
```

### 4. **UI/UX 實作**

**Material Design（Android 風格）**
```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  ),
  home: Scaffold(
    appBar: AppBar(title: const Text('Material Design')),
    body: const Center(child: Text('Hello')),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
  ),
);
```

**Cupertino（iOS 風格）**
```dart
CupertinoApp(
  theme: const CupertinoThemeData(
    primaryColor: CupertinoColors.activeBlue,
  ),
  home: CupertinoPageScaffold(
    navigationBar: const CupertinoNavigationBar(
      middle: Text('iOS Style'),
    ),
    child: const Center(child: Text('Hello')),
  ),
);
```

**響應式佈局**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  },
);
```

### 5. **效能優化**

```dart
// ✅ 使用 const constructors
const Text('Hello');  // 不會重建
Text('Hello');        // 每次都重建

// ✅ 使用 ListView.builder（虛擬列表）
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => ListTile(
    title: Text('Item $index'),
  ),
);

// ✅ 使用 RepaintBoundary（隔離重繪）
RepaintBoundary(
  child: ComplexWidget(),
);

// ✅ 快取圖片
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
);
```

### 6. **跨平台整合**

```dart
// Platform Channels - 呼叫原生程式碼
class BatteryLevel {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  Future<int> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      return result;
    } catch (e) {
      return -1;
    }
  }
}

// 平台判斷
if (Platform.isIOS) {
  // iOS 特定邏輯
} else if (Platform.isAndroid) {
  // Android 特定邏輯
}
```

### 7. **測試**

**Widget 測試**
```dart
testWidgets('Login button shows loading', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // 點擊按鈕
  await tester.tap(find.text('Login'));
  await tester.pump();

  // 驗證出現 loading
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

**Unit 測試**
```dart
test('Calculate total price', () {
  final cart = ShoppingCart();
  cart.addItem(Item(price: 50));
  cart.addItem(Item(price: 50));

  expect(cart.totalPrice, equals(100));
});
```

---

## 📋 程式碼品質標準

### 通用原則

1. **可讀性優先** - 寫清楚的程式碼，不耍花招
2. **可測試性** - 設計容易測試的程式碼
3. **一致性** - 遵循專案慣例
4. **效能意識** - 考慮執行效率

### Flutter 特定標準

Flutter Expert 遵循兩大官方風格指南：
- 📖 [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) - Dart 語言通用規範
- 📖 [Flutter Repo Style Guide](https://github.com/flutter/flutter/blob/master/docs/contributing/Style-guide-for-Flutter-repo.md) - Flutter 官方倉庫風格規範

#### 核心原則

✅ **可讀性優先於一切** - 程式碼被閱讀的次數遠多於被撰寫的次數
✅ **Getters 應該要高效（O(1) 操作）** - 耗時操作應使用回傳 Future 的 methods
✅ **避免同步的慢速操作** - 不要阻塞 UI 線程
✅ **大量使用 assert** - 盡早捕捉約定違反
✅ **實作 toString()** - 方便除錯；需要時實作 `operator ==` 和 `hashCode`

#### ✅ 使用 const 優化效能
```dart
// ✅ 好
const Text('Hello');
const Padding(padding: EdgeInsets.all(8.0));

// ❌ 不好
Text('Hello');
Padding(padding: EdgeInsets.all(8.0));
```

#### ✅ 適當的 key 使用
```dart
// ✅ 好 - 使用 key 幫助 Flutter 識別 widget
ListView.builder(
  key: PageStorageKey('posts_list'),
  itemBuilder: (context, index) => PostItem(
    key: ValueKey(posts[index].id),
    post: posts[index],
  ),
);

// ❌ 不好 - 沒有 key，可能導致狀態錯亂
ListView.builder(
  itemBuilder: (context, index) => PostItem(
    post: posts[index],
  ),
);
```

#### ✅ Null safety
```dart
// ✅ 好
String? userName;  // 可為 null
String email = '';  // 不可為 null
int? userId;

// ❌ 不好（舊版 Dart）
String userName;  // 可能為 null，但沒標示
```

#### ✅ 清楚的命名
```dart
// ✅ 好
class UserProfileWidget extends StatelessWidget { }
class LoginButton extends StatelessWidget { }
void fetchUserData() { }

// ❌ 不好
class UPW extends StatelessWidget { }
class Btn extends StatelessWidget { }
void fetch() { }
```

---

## 🛠️ 開發流程

### 1️⃣ 先分析專案

Flutter Expert 在開始工作前會：
- ✅ 檢查專案結構
- ✅ 查看 `pubspec.yaml` 依賴
- ✅ 了解現有的狀態管理方案
- ✅ 理解架構模式
- ✅ **偵測 OpenAPI 規範**：如果發現 `openapi.yaml`、`openapi.json`、`swagger.yaml` 或 `swagger.json`，會建議使用 `flutter-openapi-generator` skill 自動產生 type-safe 的 API 客戶端程式碼
- ✅ **偵測平台整合需求**：如果需要操作 `ios/` 或 `android/` 目錄、平台特定配置（`Info.plist`、`AndroidManifest.xml`）、或實作 platform channels，會建議使用 `flutter-platform-integration` skill 取得原生程式碼整合指導

### 2️⃣ 狀態管理策略

- ✅ 識別現有方案（Provider? Bloc?）
- ✅ 保持一致性
- ✅ 根據複雜度推薦合適方案
- ✅ 確保正確的資源釋放

### 3️⃣ 效能優化

```dart
// 減少不必要的 rebuild
const MyWidget();  // 使用 const

// 高效的列表渲染
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// 使用適當的快取策略
CachedNetworkImage(imageUrl: url);
```

### 4️⃣ 測試策略

提供完整的測試建議和範例程式碼。

---

## 📝 實際使用範例

### 範例 1: 建立登入畫面

**你的請求**：
```
"幫我建立一個登入畫面，包含 email 和密碼欄位"
```

**Flutter Expert 會提供**：

```dart
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 實作登入邏輯
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登入'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Email 欄位
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入 Email';
                    }
                    if (!value.contains('@')) {
                      return '請輸入有效的 Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密碼欄位
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入密碼';
                    }
                    if (value.length < 6) {
                      return '密碼至少需要 6 個字元';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // 錯誤訊息
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // 登入按鈕
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('登入'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**包含的最佳實踐**：
- ✅ 使用 `const` constructors
- ✅ 正確的資源釋放（dispose）
- ✅ 表單驗證
- ✅ Loading 狀態處理
- ✅ 錯誤處理
- ✅ 安全區域（SafeArea）
- ✅ 響應式佈局

---

### 範例 2: 效能優化

**你的問題**：
```
"這個列表滑動很卡，怎麼辦？"
```

**Flutter Expert 會分析並提供**：

```dart
// ❌ 效能不佳的寫法
class BadListExample extends StatelessWidget {
  final List<Item> items;

  const BadListExample({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      // 一次建立所有 widget
      children: items.map((item) => ItemWidget(item)).toList(),
    );
  }
}

// ✅ 優化後的寫法
class GoodListExample extends StatelessWidget {
  final List<Item> items;

  const GoodListExample({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // 只建立可見的 widget
      itemCount: items.length,
      itemExtent: 80.0,  // 固定高度，提升效能
      itemBuilder: (context, index) {
        return ItemWidget(
          key: ValueKey(items[index].id),  // 使用 key
          item: items[index],
        );
      },
    );
  }
}

// ✅ 更進階：使用 const 和 RepaintBoundary
class OptimizedItemWidget extends StatelessWidget {
  final Item item;

  const OptimizedItemWidget({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListTile(
        leading: const Icon(Icons.article),  // const
        title: Text(item.title),
        subtitle: Text(item.description),
      ),
    );
  }
}
```

**優化說明**：
1. ✅ 使用 `ListView.builder` 而非 `ListView`
2. ✅ 設定 `itemExtent` 固定高度
3. ✅ 使用 `ValueKey` 幫助 Flutter 識別項目
4. ✅ 使用 `const` constructors
5. ✅ 使用 `RepaintBoundary` 隔離重繪

---

## 🎯 品質保證檢查

完成實作前，Flutter Expert 會確認：

- ✅ 程式碼可以編譯，無錯誤或警告
- ✅ Null safety 正確處理
- ✅ 響應式設計，適配不同螢幕尺寸
- ✅ 狀態管理正確
- ✅ 資源正確釋放（dispose）
- ✅ 邊界條件和錯誤場景測試

---

## 🔗 與 Skills 的協作

遇到特定需求時，可以調用專項 skills：

### 安全審查
```
你: "檢查這段程式碼的安全性"
→ 觸發 flutter-security-review skill

檢查項目：
- 資料儲存安全（flutter_secure_storage）
- API 呼叫安全（HTTPS、certificate pinning）
- 權限處理
- 輸入驗證
- 敏感資料處理
```

### 效能優化
```
你: "優化這個 Widget 的效能"
→ 觸發 flutter-performance-review skill

檢查項目：
- Widget rebuild 優化
- 記憶體洩漏
- 渲染效能
- 列表滾動效能
- 圖片載入優化
```

### API 客戶端生成
```
你: "從 OpenAPI 規範生成 API 客戶端"
→ 觸發 flutter-openapi-generator skill

自動執行：
- 偵測 openapi.yaml 或 swagger.json
- 安裝必要套件（dio, retrofit, json_serializable）
- 配置程式碼生成器
- 執行程式碼生成
- 建立 API 服務包裝器
- 提供使用範例和最佳實踐
```

### 平台整合
```
你: "新增 iOS 相機權限"
你: "實作 Platform Channel 取得電量"
你: "設定 Android 推播通知"
→ 觸發 flutter-platform-integration skill

自動提供：
- iOS/Android 平台配置指導（Info.plist、AndroidManifest.xml）
- Platform Channels 實作（Method/Event Channels）
- 原生程式碼範例（Swift/Kotlin）
- 權限處理完整流程
- 雙平台 UI 適配策略
- Build 和簽署配置
```

---

## 💡 Flutter Expert vs 手動開發

### 沒有 Flutter Expert
```
你: 自己查文件
  → 試錯
  → Google
  → Stack Overflow
  → 再試錯

⏱️ 花費 2 小時
❓ 不確定是否最佳實踐
⚠️ 可能有效能問題
```

### 有 Flutter Expert
```
你: "建立一個購物車頁面"

Flutter Expert:
  ✅ 立即提供符合最佳實踐的程式碼
  ✅ 考慮效能優化
  ✅ 包含錯誤處理
  ✅ 提供測試建議
  ✅ 響應式設計

⏱️ 花費 10 分鐘
✨ 高品質、可維護的程式碼
```

---

## 🎯 適用對象

| 使用者 | 獲得的幫助 |
|--------|----------|
| **Flutter 初學者** | 學習最佳實踐、避免常見錯誤、快速上手 |
| **中級開發者** | 提升程式碼品質、學習進階技巧、效能優化 |
| **資深開發者** | 提高開發效率、程式碼審查、架構建議 |
| **開發團隊** | 統一程式碼風格、知識分享、品質控管 |

---

## 📚 相關資源

### 官方文件
- [Flutter 官方文件](https://docs.flutter.dev/)
- [Dart 語言指南](https://dart.dev/guides)
- [Flutter Widget 目錄](https://docs.flutter.dev/reference/widgets)

### 學習資源
- [Flutter 實用教學](https://flutter.dev/learn)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter 效能最佳實踐](https://docs.flutter.dev/perf/best-practices)

### 相關 Skills
- **flutter-security-review** - 安全審查
- **flutter-performance-review** - 效能優化
- **flutter-openapi-generator** - API 客戶端生成
- **flutter-platform-integration** - 平台整合與原生程式碼

---

## 🚀 開始使用

### 1. 在 Flutter 專案中
只要在 Flutter 專案目錄中，Flutter Expert 會自動啟動協助。

### 2. 詢問任何 Flutter 相關問題
```
"建立一個底部導航列"
"如何實作下拉刷新？"
"這段程式碼有什麼問題？"
"優化這個頁面的效能"
```

### 3. 程式碼審查
編輯 `.dart` 檔案時，Flutter Expert 會主動審查並提供建議。

### 4. 深入審查
需要完整的安全或效能審查時：
```
"檢查整個 app 的安全性"  → 觸發 flutter-security-review
"全面優化 app 效能"     → 觸發 flutter-performance-review
```

---

## 💬 總結

**Flutter Expert Agent 就像你的專屬 Flutter 導師**，提供：

- 🤖 自動協助（偵測 Flutter 專案自動啟動）
- 💻 高品質程式碼（符合最佳實踐）
- 🚀 效能優化（自動考慮效能）
- 🧪 測試支援（提供測試策略）
- 🔍 程式碼審查（主動審查並建議）
- 📚 知識傳承（學習最佳實踐）
- 🎨 雙平台支援（Material + Cupertino）

讓 Flutter 開發變得更簡單、更快速、更專業！🎉

---

**相關檔案**：
- Agent 定義：`agents/flutter-expert.md`
- 安全審查 Skill：`skills/flutter-security-review/SKILL.md`
- 效能優化 Skill：`skills/flutter-performance-review/SKILL.md`
- API 客戶端生成 Skill：`skills/flutter-openapi-generator/SKILL.md`
- 平台整合 Skill：`skills/flutter-platform-integration/SKILL.md`
