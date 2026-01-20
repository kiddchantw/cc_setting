# React 最佳實踐指南

來自 Vercel Engineering 的 React 與 Next.js 效能優化指南，包含 40+ 條規則，分為 8 個優先級類別。


https://github.com/vercel-labs/agent-skills/blob/react-best-practices/skills/react-best-practices/SKILL.md


---

## 🚀 觸發指令

### 精準觸發
- `@react-best-practices`
- `使用 react-best-practices`

### 語義觸發
- "React 最佳實踐"
- "優化 React 效能"
- "減少 React 重新渲染"
- "檢查 React 程式碼品質"

## 適用時機

- 撰寫新的 React 元件或 Next.js 頁面
- 實作資料獲取（客戶端或伺服器端）
- 審查程式碼的效能問題
- 重構現有的 React/Next.js 程式碼
- 優化打包大小或載入時間

---

## 優先級排序

| 優先級 | 類別 | 影響程度 |
|--------|------|----------|
| 1 | 消除瀑布流 | 🔴 關鍵 |
| 2 | 打包大小優化 | 🔴 關鍵 |
| 3 | 伺服器端效能 | 🟠 高 |
| 4 | 客戶端資料獲取 | 🟡 中高 |
| 5 | 重新渲染優化 | 🟢 中 |
| 6 | 渲染效能 | 🟢 中 |
| 7 | JavaScript 效能 | 🔵 低中 |
| 8 | 進階模式 | 🔵 低 |

---

## 關鍵模式（優先處理）

### 1. 消除瀑布流 (Waterfalls)

瀑布流是指多個非同步操作按順序執行，而非並行執行，導致總延遲時間累加。

#### ❌ 錯誤做法
```typescript
// 瀑布流：總時間 = A + B + C
const dataA = await fetchA();
const dataB = await fetchB();
const dataC = await fetchC();
```

#### ✅ 正確做法
```typescript
// 並行：總時間 = max(A, B, C)
const [dataA, dataB, dataC] = await Promise.all([
  fetchA(),
  fetchB(),
  fetchC()
]);
```

#### 關鍵規則

| 規則 | 說明 |
|------|------|
| 延遲 await | 將 await 移到真正需要資料的地方 |
| Promise.all() | 對獨立的非同步操作使用並行執行 |
| 早啟動晚等待 | 先啟動 Promise，在需要時才 await |
| Suspense 串流 | 使用 Suspense boundaries 串流內容 |

### 2. 打包大小優化 (Bundle Size)

#### ❌ 錯誤做法：Barrel File 匯入
```typescript
// 匯入整個模組，即使只用一個函式
import { Button } from '@/components';
import { formatDate } from '@/utils';
```

#### ✅ 正確做法：直接匯入
```typescript
// 只匯入需要的檔案
import { Button } from '@/components/Button';
import { formatDate } from '@/utils/date';
```

#### 關鍵規則

| 規則 | 說明 |
|------|------|
| 避免 barrel files | 直接從源檔案匯入，而非 index.ts |
| next/dynamic | 對大型元件使用動態載入 |
| 延遲第三方庫 | 非關鍵函式庫延遲載入 |
| 意圖預載 | 根據使用者意圖預先載入 |

#### 動態載入範例
```typescript
import dynamic from 'next/dynamic';

// 延遲載入大型元件
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false  // 若只在客戶端需要
});
```

---

## 高影響：伺服器端效能

### React Server Components (RSC) 模式

#### React.cache() - 請求級去重
```typescript
import { cache } from 'react';

// 同一請求內多次呼叫只執行一次
export const getUser = cache(async (id: string) => {
  return await db.user.findUnique({ where: { id } });
});
```

#### LRU Cache - 跨請求快取
```typescript
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, Data>({
  max: 500,
  ttl: 1000 * 60 * 5  // 5 分鐘
});

export async function getData(key: string) {
  if (cache.has(key)) return cache.get(key);
  const data = await fetchData(key);
  cache.set(key, data);
  return data;
}
```

#### 並行資料獲取
```typescript
// 在佈局層級並行啟動資料獲取
export default async function Layout({ children }) {
  // 並行啟動，不要 await
  const userPromise = getUser();
  const settingsPromise = getSettings();

  return (
    <UserProvider userPromise={userPromise}>
      <SettingsProvider settingsPromise={settingsPromise}>
        {children}
      </SettingsProvider>
    </UserProvider>
  );
}
```

---

## 中高影響：客戶端資料獲取

### SWR 自動去重
```typescript
import useSWR from 'swr';

function Profile() {
  // 相同 key 的多個元件只發一次請求
  const { data, error, isLoading } = useSWR('/api/user', fetcher);

  if (isLoading) return <Skeleton />;
  if (error) return <Error />;
  return <div>{data.name}</div>;
}
```

### 延遲狀態讀取
```typescript
// ❌ 不好：每次渲染都計算
function Component() {
  const items = useStore(state => state.items);
  const total = items.reduce((sum, i) => sum + i.price, 0);
}

// ✅ 好：只在需要時讀取
function Component() {
  const total = useStore(state =>
    state.items.reduce((sum, i) => sum + i.price, 0)
  );
}
```

### 惰性初始化
```typescript
// ❌ 不好：每次渲染都執行
const [data, setData] = useState(expensiveComputation());

// ✅ 好：只在首次渲染執行
const [data, setData] = useState(() => expensiveComputation());
```

---

## 中等影響：重新渲染優化

### startTransition 非緊急更新
```typescript
import { startTransition } from 'react';

function SearchInput() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  const handleChange = (e) => {
    // 緊急：立即更新輸入框
    setQuery(e.target.value);

    // 非緊急：可以延遲的搜尋結果
    startTransition(() => {
      setResults(search(e.target.value));
    });
  };
}
```

### 明確條件渲染
```typescript
// ❌ 可能渲染 0 或 false
{count && <Badge count={count} />}

// ✅ 明確的三元運算
{count > 0 ? <Badge count={count} /> : null}
```

---

## 中等影響：渲染效能

### 長列表優化
```css
/* 對長列表使用 content-visibility */
.list-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 50px;
}
```

### SVG 動畫
```typescript
// ❌ 不好：直接動畫 SVG 元素
<svg animate={{ rotate: 360 }}>...</svg>

// ✅ 好：動畫包裝元素
<motion.div animate={{ rotate: 360 }}>
  <svg>...</svg>
</motion.div>
```

### 避免 Hydration 不匹配
```typescript
// 使用內聯腳本設定初始主題，避免閃爍
<script dangerouslySetInnerHTML={{
  __html: `
    const theme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', theme);
  `
}} />
```

---

## JavaScript 效能模式

### 批次 DOM 操作
```typescript
// ❌ 不好：多次觸發重排
element.style.width = '100px';
element.style.height = '100px';
element.style.margin = '10px';

// ✅ 好：一次性透過 class 變更
element.classList.add('expanded');
```

### 索引快取
```typescript
// ❌ 不好：每次都 O(n) 查找
users.find(u => u.id === id);

// ✅ 好：建立索引 O(1) 查找
const userById = new Map(users.map(u => [u.id, u]));
userById.get(id);
```

### 不可變排序
```typescript
// ❌ 不好：修改原陣列
const sorted = items.sort((a, b) => a.name.localeCompare(b.name));

// ✅ 好：回傳新陣列
const sorted = items.toSorted((a, b) => a.name.localeCompare(b.name));
```

---

## 參考資源

- [Vercel Agent Skills - React Best Practices](https://github.com/vercel-labs/agent-skills/tree/react-best-practices)
- [React Server Components](https://react.dev/reference/rsc/server-components)
- [Next.js Performance](https://nextjs.org/docs/app/building-your-application/optimizing)
