# Flutter Performance Review Skill 使用指南

## 🎯 這個 Skill 是什麼？

**Flutter Performance Review** 是一個專門優化 Flutter 應用程式**效能問題和診斷效能瓶頸**的工具。

簡單來說：
- 幫你找出效能問題的根源 🔍
- 優化 Widget 重建和渲染 ⚡
- 減少記憶體洩漏 🧹
- 提升應用流暢度到 60fps 🚀

---

## 🚀 自動觸發條件

這個 skill 會在以下情況**自動啟動**：

### 效能問題症狀
- App 執行緩慢或卡頓
- UI 在滾動或動畫時掉幀（jank）
- 記憶體消耗過高
- Widget 過度重建
- 啟動時間過長
- App bundle 大小過大
- 幀率低於 60fps

### 使用者請求
- "優化這個 widget"
- "為什麼會卡頓？"
- "減少 rebuilds"
- "improve performance"
- "memory leak check"
- "app is slow"
- "優化效能"
- "記憶體洩漏"

---

## ⚡ 效能優化檢查清單

### 1. Widget 優化

**檢查項目**：
- ✅ 盡可能使用 `const` constructors 減少重建
- ✅ 實作適當的 widget key 用法以提升重建效率
- ✅ 將大型 widgets 拆分成較小、可重用的元件
- ✅ 最小化 widget tree 深度
- ✅ 對不常變化的複雜 widgets 使用 `RepaintBoundary`
- ✅ 避免在 build methods 中執行昂貴的操作

**範例**：

```dart
// ❌ 效能不佳
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('Title'),  // 每次 rebuild 都會重建
          Icon(Icons.star),  // 每次 rebuild 都會重建
        ],
      ),
    );
  }
}

// ✅ 優化後
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: const [  // 使用 const
          Text('Title'),
          Icon(Icons.star),
        ],
      ),
    );
  }
}

// ✅ 更好：使用 RepaintBoundary 隔離重繪
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        child: Column(
          children: const [
            Text('Title'),
            Icon(Icons.star),
          ],
        ),
      ),
    );
  }
}
```

### 2. Rebuild 優化

**檢查項目**：
- ✅ 透過選擇性監聽最小化 widget rebuilds
- ✅ 對簡單的狀態更新使用 `ValueListenableBuilder`
- ✅ 在自訂 widgets 中適當實作 `shouldRebuild`
- ✅ 適當分離 stateful 和 stateless widgets
- ✅ 對動畫使用 `AnimatedBuilder` 而非 `setState`
- ✅ 避免不必要地使用 global keys

**範例**：

```dart
// ❌ 效能不佳：整個 widget tree rebuild
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpensiveWidget(),  // 每次 _counter 改變都會 rebuild
        Text('Count: $_counter'),
        ElevatedButton(
          onPressed: () => setState(() => _counter++),
          child: Text('Increment'),
        ),
      ],
    );
  }
}

// ✅ 優化後：只 rebuild 需要的部分
class CounterWidget extends StatefulWidget {
  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  final _counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ExpensiveWidget(),  // 不會 rebuild
        ValueListenableBuilder<int>(
          valueListenable: _counter,
          builder: (context, count, child) {
            return Text('Count: $count');  // 只有這裡 rebuild
          },
        ),
        ElevatedButton(
          onPressed: () => _counter.value++,
          child: const Text('Increment'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }
}
```

### 3. 列表與滾動效能

**檢查項目**：
- ✅ 使用 `ListView.builder` 或 `ListView.separated` 實作高效列表渲染
- ✅ 對網格佈局使用 `GridView.builder`
- ✅ 對長列表實作延遲載入
- ✅ 使用 `itemExtent` 或 `prototypeItem` 快取列表項目大小
- ✅ 使用 `AutomaticKeepAliveClientMixin` 保留列表項目狀態
- ✅ 對大型資料集實作分頁
- ✅ 避免在 `itemBuilder` 中執行昂貴的計算

**範例**：

```dart
// ❌ 效能不佳：一次建立所有項目
class MyListView extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items.map((item) => ItemWidget(item)).toList(),
    );
  }
}

// ✅ 優化後：使用 ListView.builder
class MyListView extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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

// ✅ 更好：加上 RepaintBoundary 和 const
class ItemWidget extends StatelessWidget {
  final Item item;

  const ItemWidget({required this.item, Key? key}) : super(key: key);

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

### 4. 圖片優化

**檢查項目**：
- ✅ 使用快取和適當解析度優化圖片載入
- ✅ 對網路圖片使用 `CachedNetworkImage`
- ✅ 將圖片調整為適當尺寸（避免大圖）
- ✅ 使用圖片壓縮（推薦 WebP 格式）
- ✅ 實作 placeholder 和淡入效果
- ✅ 預載入關鍵圖片
- ✅ 有效使用 `Image.memory` 或 `Image.asset`

**範例**：

```dart
// ❌ 效能不佳：未快取的網路圖片
Image.network(
  'https://example.com/large-image.jpg',
  width: 100,
  height: 100,
)

// ✅ 優化後：使用 CachedNetworkImage
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: 'https://example.com/image.webp',  // 使用 WebP
  width: 100,
  height: 100,
  placeholder: (context, url) => Container(
    color: Colors.grey[300],
    child: const Center(child: CircularProgressIndicator()),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 100 * MediaQuery.of(context).devicePixelRatio.toInt(),
  memCacheHeight: 100 * MediaQuery.of(context).devicePixelRatio.toInt(),
)

// ✅ 預載入關鍵圖片
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  precacheImage(
    CachedNetworkImageProvider('https://example.com/hero-image.webp'),
    context,
  );
}
```

### 5. 記憶體管理

**檢查項目**：
- ✅ 分析記憶體使用並修復記憶體洩漏
- ✅ 適當 dispose controllers、streams 和 listeners
- ✅ 避免 StatefulWidgets 中的記憶體洩漏（dispose method）
- ✅ 對循環參照使用 `WeakReference`
- ✅ 適當時清除圖片快取
- ✅ 使用 DevTools 監控記憶體使用

**範例**：

```dart
// ❌ 記憶體洩漏
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // 處理資料
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
  // ❌ 沒有 dispose！
}

// ✅ 正確的資源管理
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // 處理資料
    });
  }

  @override
  void dispose() {
    _controller.dispose();  // ✅ 釋放 controller
    _subscription?.cancel();  // ✅ 取消訂閱
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(controller: _controller);
  }
}
```

### 6. 運算效能

**檢查項目**：
- ✅ 對繁重的運算任務使用 isolates
- ✅ 將昂貴的操作移出 UI thread
- ✅ 對一次性運算使用 `compute()` 函數
- ✅ 對資料解析實作背景處理
- ✅ 優化演算法複雜度（Big O）
- ✅ 對昂貴的函數結果使用 memoization

**範例**：

```dart
// ❌ 效能不佳：在 UI thread 執行繁重運算
Future<List<Data>> parseData(String jsonString) {
  final list = json.decode(jsonString) as List;
  return list.map((item) => Data.fromJson(item)).toList();
}

// 在 build 或 initState 中呼叫
final data = await parseData(largeJsonString);  // ❌ 阻塞 UI

// ✅ 優化後：使用 compute 在背景執行
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Top-level 函數或靜態方法
List<Data> _parseDataInBackground(String jsonString) {
  final list = json.decode(jsonString) as List;
  return list.map((item) => Data.fromJson(item)).toList();
}

// 使用 compute
Future<List<Data>> parseData(String jsonString) async {
  return await compute(_parseDataInBackground, jsonString);
}

// ✅ 更好：使用 Isolate 進行持續的背景處理
import 'dart:isolate';

class DataProcessor {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;

  Future<void> init() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateEntry, _receivePort!.sendPort);
    _sendPort = await _receivePort!.first;
  }

  static void _isolateEntry(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      // 處理資料
      final result = _processData(message);
      sendPort.send(result);
    });
  }

  Future<dynamic> process(dynamic data) async {
    _sendPort!.send(data);
    return await _receivePort!.first;
  }

  void dispose() {
    _isolate?.kill();
    _receivePort?.close();
  }
}
```

### 7. App Bundle 與啟動優化

**檢查項目**：
- ✅ 移除未使用的資源以最小化 app bundle 大小
- ✅ 對非關鍵功能使用延遲載入
- ✅ 優化 asset 壓縮
- ✅ 移除未使用的依賴
- ✅ 使用 tree-shaking（release builds 自動執行）
- ✅ 實作 splash screen 優化
- ✅ 延遲非關鍵初始化

**範例**：

```bash
# 分析 app 大小
flutter build apk --analyze-size
flutter build ios --analyze-size

# 檢查未使用的依賴
flutter pub deps
flutter pub outdated

# 移除未使用的程式碼（自動在 release build）
flutter build apk --release
```

```dart
// ✅ 延遲初始化
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // ✅ 只初始化關鍵服務
    await criticalService.init();

    // ✅ 延遲初始化非關鍵服務
    Future.delayed(Duration(seconds: 1), () {
      nonCriticalService.init();
    });

    // 導航到主畫面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

### 8. 動畫效能

**檢查項目**：
- ✅ 對高效動畫使用 `AnimatedBuilder` 和 `AnimatedWidget`
- ✅ 優先使用 `Transform` 而非位置變更
- ✅ 謹慎使用 `Opacity` widget（昂貴）
- ✅ 盡可能快取動畫值
- ✅ 適當使用 `TickerProviderStateMixin`
- ✅ 避免為大型 widget subtrees 做動畫

**範例**：

```dart
// ❌ 效能不佳：使用 setState 做動畫
class MyAnimation extends StatefulWidget {
  @override
  _MyAnimationState createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..addListener(() {
        setState(() {});  // ❌ 整個 widget rebuild
      });
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.rotationZ(_controller.value * 2 * pi),
      child: ExpensiveWidget(),
    );
  }
}

// ✅ 優化後：使用 AnimatedBuilder
class MyAnimation extends StatefulWidget {
  @override
  _MyAnimationState createState() => _MyAnimationState();
}

class _MyAnimationState extends State<MyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,  // child 不會 rebuild
        );
      },
      child: const ExpensiveWidget(),  // ✅ const，不會 rebuild
    );
  }
}

// ✅ 避免昂貴的 Opacity 動畫
// ❌ 不好
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: ExpensiveWidget(),
)

// ✅ 好：使用 FadeTransition
FadeTransition(
  opacity: _animation,
  child: const ExpensiveWidget(),
)
```

---

## 🔧 效能分析工具

### Flutter DevTools

**使用方式**：
```bash
# 啟動 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 或在 IDE 中直接開啟
```

**功能**：
- ✅ **Performance overlay** - 識別 jank
- ✅ **Timeline view** - 分析幀渲染
- ✅ **Memory view** - 偵測記憶體洩漏
- ✅ **Network profiler** - 監控 API 呼叫
- ✅ **CPU profiler** - 找出瓶頸

### 命令列工具

```bash
# 效能 overlay
flutter run --profile  # 使用 profile mode

# 分析 app 大小
flutter build apk --analyze-size
flutter build ios --analyze-size

# 檢查效能問題
flutter analyze
```

### Widget 效能分析

```dart
import 'package:flutter/rendering.dart';

void enablePerformanceOverlay() {
  // 啟用效能 overlay
  debugProfileBuildsEnabled = true;
  debugProfilePaintsEnabled = true;

  // 檢查 rebuild 頻率
  debugPrintRebuildDirtyWidgets = true;
}
```

---

## 🐛 常見效能問題

### 1. 過度 Rebuilds

**症狀**：UI 感覺遲緩，CPU 使用率高

**解決方案**：
- 使用 `const` constructors
- 實作適當的狀態管理範圍
- 使用 `ValueListenableBuilder` 或類似方案

### 2. N+1 渲染問題

**症狀**：列表滾動卡頓

**解決方案**：
- 使用 `ListView.builder`
- 實作適當的項目回收
- 快取項目高度

### 3. 記憶體洩漏

**症狀**：App 崩潰，記憶體無限增長

**解決方案**：
- 適當 dispose controllers
- 取消訂閱 streams
- 使用 DevTools memory profiler

### 4. 大型圖片

**症狀**：圖片載入慢，記憶體高

**解決方案**：
- 調整圖片為適當大小
- 使用快取策略
- 壓縮圖片

### 5. 同步阻塞操作

**症狀**：操作期間 UI 凍結

**解決方案**：
- 使用 isolates 或 `compute()`
- 移至背景 thread
- 適當實作 async/await

---

## 📊 效能指標追蹤

### 關鍵指標
- **幀渲染時間**：< 16ms (60fps)
- **App 啟動時間**：< 3 秒
- **記憶體使用**：穩定，無洩漏
- **Bundle 大小**：盡可能小
- **網路請求**：已快取並優化
- **電池使用**：最小化背景活動

### 測試方式

```dart
// 測量 widget 建置時間
import 'package:flutter/foundation.dart';

void measureBuildTime(Widget widget) {
  final stopwatch = Stopwatch()..start();

  // Build widget
  widget.createElement();

  stopwatch.stop();
  debugPrint('Build time: ${stopwatch.elapsedMilliseconds}ms');
}
```

---

## 🎯 效能最佳實踐

1. **先測量**：使用分析工具後再優化
2. **優化熱路徑**：專注於頻繁執行的程式碼
3. **在真實裝置上測試**：模擬器無法反映真實效能
4. **分析 Release Builds**：Debug builds 較慢
5. **設定效能目標**：以 60fps（每幀 16ms）為目標
6. **監控記憶體**：保持記憶體使用穩定
7. **逐步優化**：進行小幅、可測量的改進

---

## 📱 平台特定優化

### Android
- 使用 R8/ProGuard 進行程式碼縮減
- 必要時啟用 multidex
- 優化原生庫載入
- 使用 Skia 渲染引擎優化

### iOS
- 啟用 bitcode（如適用）
- 優化 asset catalogs
- 使用 Metal 進行圖形處理
- 使用 Instruments 進行分析

---

## 📚 相關資源

### 官方文件
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Performance profiling](https://docs.flutter.dev/perf/ui-performance)

### 推薦套件
- **flutter_performance_logger** - 效能日誌
- **cached_network_image** - 圖片快取
- **dio** - 高效能 HTTP 客戶端
- **hive** - 輕量級快速資料庫

---

## 💡 總結

**Flutter Performance Review Skill** 幫你：

- ⚡ **找出瓶頸** - 快速定位效能問題
- 🚀 **提升流暢度** - 達到 60fps 目標
- 🧹 **減少記憶體** - 修復記憶體洩漏
- 📊 **可測量改進** - 數據驅動優化
- 🎯 **最佳實踐** - 遵循業界標準
- 💪 **生產就緒** - 確保 app 效能優異

**讓你的 Flutter 應用快如閃電！** ⚡🎉

---

**相關檔案**：
- Skill 定義：`skills/flutter-performance-review/SKILL.md`
- Agent 定義：`agents/flutter-expert.md`
- Flutter Expert 繁中指南：`README_flutter-expert_zh_TW.md`
