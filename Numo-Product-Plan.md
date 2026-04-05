# Numo - iOS 原生数字效率工具箱 完整落地方案

## Context

构建一款以计算器为核心入口的原生 iOS 数字效率工具箱 App，面向所有与数字打交道的商务人士。英文名 **Numo**（中文名待定）。用户（产品负责人）不写代码，Claude 负责全部技术实现。

**核心理念：** 一个入口，多种变形 —— 计算器永远是主角，工具按需切换，计算结果可手动流转到各工具。

---

## 1. 产品定义

### 1.1 目标用户
通用商务人群：财务/会计、销售/运营、创业者、泛办公白领。不限定单一角色。

### 1.2 设计风格
极简克制，Apple 原生设计语言。大量留白，黑白灰为主，色彩仅用于语义表达（成功/错误/趋势）。

### 1.3 语言支持
v1 中英双语（en + zh-Hans），使用 Xcode String Catalogs。

### 1.4 商业模式
先做产品，商业化后议。v1 无付费逻辑。

---

## 2. 交互架构

### 2.1 核心布局
```
┌─────────────────────────────────────┐
│  表达式区域（可编辑，显示完整算式+结果）   │
│  1,200 × 0.8 + 500 = 1,460          │
├─────────────────────────────────────┤
│ [计算器] [汇率] [大写] [同比] [个税] [▸] │  ← 顶部工具栏(横向滚动)
├─────────────────────────────────────┤
│                                     │
│   下方区域随工具选择整体变形             │
│   默认=计算器键盘  汇率=货币选择+输入     │
│                                     │
├─────────────────────────────────────┤
│   ↑ 上滑抽屉查看更多工具               │
└─────────────────────────────────────┘
```

### 2.2 导航模型
- **不使用** NavigationStack/TabView，整个 App 是单屏变形器
- 选择工具 chip → 下方内容区 cross-fade 切换
- 次级页面（历史、货币选择器）使用 `.sheet()` 弹出
- 抽屉使用 `.sheet(detents: [.fraction(0.4), .large])`

### 2.3 结果流转
手动模式：算出结果后，用户点击其他工具 chip，工具的输入框自动预填 `AppState.lastResult`，用户可清空重新输入。

---

## 3. 功能模块（v1 全量上线，共 8 个模块）

### 3.1 核心计算器
- **混合模式：** 传统按键网格 + 上方可编辑表达式区域
- **表达式引擎：** Shunting-yard 算法，全程使用 `Decimal`（非 Double），确保金融精度
- **按键布局：** 竖屏 5×4 网格（AC/±/%/÷ | 7/8/9/× | 4/5/6/- | 1/2/3/+ | 0(宽)/./ =）
- **横屏：** 扩展科学计算（sin/cos/tan/log/ln/√/x²/xⁿ/π/e）
- **计算历史：** SwiftData 持久化，支持搜索、收藏、按日期分组
- **智能百分比：** `10%` 单独=0.1，`200+10%`=220，`200*10%`=20

### 3.2 汇率换算
- API: frankfurter.app（免费，无需 Key，ECB 数据源）
- 离线缓存：SwiftData 存储最近汇率，>1h 自动刷新，>24h 显示警告
- ~30 种常用货币，含 flag emoji + ISO 代码
- 快捷货币 chips：CNY/USD/EUR/JPY/GBP/HKD

### 3.3 数字大写转换
- 实时转换：输入金额 → 人民币大写（壹仟贰佰圆整）
- 支持范围：0 ~ 9999亿9999万9999.99
- 规则：连续零合并、角分整规则、负数前缀"负"
- 一键复制结果

### 3.4 同比环比计算
- 分段控制：同比(YoY) / 环比(MoM)
- 输入本期值 + 上期值 → 输出百分比变化 + 绝对变化 + 趋势箭头
- 公式：(本期-上期) / |上期| × 100%
- 颜色语义：增长=绿，下降=红

### 3.5 个税计算器
- 中国累计预扣法，7 级超额累进税率
- 社保五险一金（养老8%/医疗2%/失业0.5%/公积金5-12%可调）
- 专项附加扣除（子女教育/继续教育/大病医疗/房贷/房租/赡养/婴幼儿）
- 输出：税后月薪、月度个税（12个月各不同）、年度汇总、有效税率
- 城市选择影响社保基数上下限

### 3.6 日期计算器
- 三种模式：日期间隔 / 日期推算 / 工作日计算
- 工作日计算支持排除中国法定节假日（含调休补班）
- 节假日数据：打包 JSON 文件（2024-2027），来源国务院公告

### 3.7 单位换算
- 5 大类：面积/重量/长度/数据存储/温度
- 含中国特色单位：亩（666.67m²）、斤（500g）、两（50g）
- 温度使用特殊公式（非线性）
- 全程 Decimal 精度

### 3.8 贷款计算器
- 两种还款方式：等额本息 / 等额本金
- 输入：贷款金额（万元）、期限、年利率
- 快捷利率：LPR 3.45% / 公积金 2.85%
- 输出：月供、总还款、总利息、还款明细表
- Decimal 迭代计算 (1+r)^n，不用 Double pow()

---

## 4. 设计系统

### 4.1 色彩
**浅色模式：** Surface=#FFF, Secondary=#F2F2F7, Text=#000, 按键白色, 等号键黑底白字, chip选中黑底白字
**深色模式：** Surface=#000, Secondary=#1C1C1E, Text=#FFF, 按键#333, 等号键白底黑字, chip选中白底黑字
**语义色：** Success=#34C759, Danger=#FF3B30, Warning=#FF9500

### 4.2 字体
San Francisco 系统字体Rounded，数字结果使用 `.monospacedDigit` 防止布局跳动：
- displayLarge: 48pt light（计算结果）
- displayMedium: 36pt light（表达式）
- titleLarge: 22pt semibold（区块标题）
- bodyLarge: 17pt regular（正文）
- keypadLarge: 28pt medium（数字键）

### 4.3 间距
4pt 网格：xxs=4, xs=8, sm=12, md=16, lg=20, xl=24, xxl=32
屏幕水平内边距=16pt，按键间距=8pt，chip间距=8pt

### 4.4 组件库
- **CalcButton:** 圆角12pt, 按下缩放0.92 spring动画, 轻触感反馈
- **ToolChip:** 胶囊形(h=36pt, r=18pt), 选中态动画0.25s
- **NumoCard:** 圆角16pt, SurfaceSecondary背景, 无阴影(扁平)
- **NumoTextField:** h=48pt, 圆角12pt, 数字输入右对齐
- **ResultBanner:** 点击复制(勾选动画+成功触感), 长按分享

### 4.5 动画
- 工具切换：出场 fade+下移8pt(0.2s) → 入场 fade+上移8pt(0.25s)
- 按键按下：scale 1→0.92→1, spring(0.2, 0.6)
- 错误：水平抖动 3次 0.4s
- 抽屉：标准 SwiftUI sheet
- 数字变化：原生contenttransition

### 4.6 触感反馈
| 事件 | 类型 | 强度 |
|------|------|------|
| 数字键 | Impact light | 0.6 |
| 运算符 | Impact light | 0.8 |
| 等号 | Impact medium | 0.9 |
| 清除 | Impact rigid | 0.5 |
| 工具切换 | Impact light | 0.5 |
| 复制结果 | Notification success | default |
| 错误 | Notification error | default |

---

## 5. 技术架构

### 5.1 模式
**MVVM + Services**，使用 Swift `@Observable` 宏（非 Combine）。

- **View:** 纯声明式，无业务逻辑
- **ViewModel:** `@Observable` 类，拥有所有可变状态和业务逻辑
- **Model:** SwiftData `@Model`（持久化）或 plain struct（瞬态）
- **Service:** 单例/Actor，通过 SwiftUI Environment 注入
- **Engine:** 纯函数，无 UI 依赖，可独立测试

### 5.2 状态管理
- `AppState`（全局 @Observable）：当前选中工具、lastResult、抽屉状态
- 各工具 ViewModel：各自独立状态，通过 `@State` 在 View 中持有
- SwiftData：历史记录、汇率缓存

### 5.3 SwiftData Schema
```swift
let schema = Schema([
    CalculationRecord.self,  // 计算历史
    ExchangeRate.self,       // 汇率缓存
])
```

### 5.4 外部依赖
**零第三方包。** 全部使用系统框架：SwiftUI + SwiftData + Foundation + URLSession。

### 5.5 关键技术决策
1. **Decimal 不用 Double** — 金融精度，`0.1+0.2==0.3` 必须为 true
2. **不用 Combine** — Swift 6 concurrency + @Observable 足够
3. **不用 NavigationStack** — 单屏变形器，非层级导航
4. **表达式引擎独立于 UI** — 纯函数，方便测试
5. **节假日数据打包而非 API** — 年更一次，更可靠
6. **累计预扣法** — 中国个税月度差异的正确算法
7. **万元为贷款输入单位** — 符合中国用户习惯

---

## 6. 文件结构

```
calculator/
├── calculatorApp.swift                 [改] 入口, SwiftData schema, Environment
├── Info.plist                          [改] 移除 remote-notification
│
├── App/
│   ├── AppState.swift                  全局状态
│   ├── NumoTabView.swift               主容器(表达式+工具栏+内容)
│   └── Constants.swift                 常量
│
├── DesignSystem/
│   ├── Theme/
│   │   ├── NumoColors.swift            色彩 tokens
│   │   ├── NumoTypography.swift        字体 scale
│   │   ├── NumoSpacing.swift           间距系统
│   │   └── NumoShadows.swift           阴影
│   ├── Components/
│   │   ├── CalcButton.swift            计算器按键
│   │   ├── ToolChip.swift              工具栏 chip
│   │   ├── NumoTextField.swift         输入框
│   │   ├── NumoCard.swift              卡片容器
│   │   ├── NumoSegmentedControl.swift  分段选择
│   │   ├── ResultBanner.swift          结果展示+复制
│   │   ├── TrendIndicator.swift        趋势箭头
│   │   └── LoadingDot.swift            加载指示
│   ├── Modifiers/
│   │   ├── HapticModifier.swift        触感修饰器
│   │   ├── ShakeModifier.swift         抖动动画
│   │   └── PressScaleModifier.swift    按压缩放
│   └── Animations/
│       ├── ToolTransition.swift        工具切换过渡
│       └── NumoAnimations.swift        共享动画曲线
│
├── Features/
│   ├── Calculator/
│   │   ├── Views/ (CalculatorView, ExpressionDisplayView, KeypadView, ScientificKeypadView, HistoryView)
│   │   ├── ViewModels/ (CalculatorViewModel, HistoryViewModel)
│   │   ├── Models/ (CalculationRecord[SwiftData], CalcToken)
│   │   └── Engine/ (ExpressionParser, ExpressionEvaluator, ExpressionFormatter, ScientificFunctions)
│   ├── CurrencyExchange/
│   │   ├── Views/ (CurrencyExchangeView, CurrencyPickerView, CurrencyRowView)
│   │   ├── ViewModels/ (CurrencyExchangeViewModel)
│   │   └── Models/ (Currency, ExchangeRate[SwiftData], CurrencyPair)
│   ├── ChineseUppercase/
│   │   ├── Views/ (ChineseUppercaseView)
│   │   ├── ViewModels/ (ChineseUppercaseViewModel)
│   │   └── Engine/ (ChineseUppercaseConverter)
│   ├── YoYCalculator/
│   │   ├── Views/ (YoYCalculatorView)
│   │   ├── ViewModels/ (YoYCalculatorViewModel)
│   │   └── Models/ (YoYResult)
│   ├── IncomeTax/
│   │   ├── Views/ (IncomeTaxView, TaxBreakdownView, SocialInsuranceInputView)
│   │   ├── ViewModels/ (IncomeTaxViewModel)
│   │   ├── Models/ (TaxBracket, SocialInsurance, TaxResult)
│   │   └── Engine/ (ChineseTaxCalculator)
│   ├── DateCalculator/
│   │   ├── Views/ (DateCalculatorView, DateDifferenceView, DateOffsetView, WorkdayCalculatorView)
│   │   ├── ViewModels/ (DateCalculatorViewModel)
│   │   ├── Models/ (DateResult)
│   │   └── Engine/ (WorkdayCalculator, ChineseHolidayData)
│   ├── UnitConverter/
│   │   ├── Views/ (UnitConverterView, UnitCategoryPickerView, UnitRowView)
│   │   ├── ViewModels/ (UnitConverterViewModel)
│   │   └── Models/ (UnitCategory, UnitDefinition)
│   └── LoanCalculator/
│       ├── Views/ (LoanCalculatorView, LoanResultView, AmortizationScheduleView)
│       ├── ViewModels/ (LoanCalculatorViewModel)
│       ├── Models/ (LoanParameters, LoanResult, AmortizationEntry)
│       └── Engine/ (LoanEngine)
│
├── Services/
│   ├── ExchangeRateService.swift       汇率 API 客户端
│   ├── HapticService.swift             触感反馈中心
│   ├── NumberFormatterService.swift     本地化数字格式
│   └── PasteboardService.swift         剪贴板工具
│
├── Shared/
│   ├── Extensions/ (Decimal+, String+, Date+, View+, Color+)
│   ├── Utilities/ (DecimalPrecision, InputValidator, Debouncer)
│   └── Protocols/ (ToolModule, ExchangeRateServiceProtocol)
│
├── Resources/
│   ├── Localizable.xcstrings           中英文字符串目录
│   └── ChineseHolidays.json           节假日数据
│
└── Assets.xcassets/
    └── Colors/ (Surface, TextPrimary, KeyDefault, KeyEquals 等 ~15 个色集)
```

**预计新增文件数：~85 个**

---

## 7. 实施阶段

### Phase 1: 地基搭建
- 1.1 清理模板代码，创建目录结构，更新 App 入口
- 1.2 设计系统实现（颜色/字体/间距/动画常量）
- 1.3 核心组件库（CalcButton/ToolChip/NumoTextField/NumoCard/ResultBanner/修饰器）
- 1.4 计算引擎（CalcToken/ExpressionParser/ExpressionEvaluator/ExpressionFormatter）+ 单元测试
- 1.5 服务层（HapticService/NumberFormatterService/PasteboardService/AppState）
- 1.6 Extensions 和工具类

### Phase 2: 核心计算器 UI
- 2.1 表达式显示区（可滚动、实时求值、数字分组格式化）
- 2.2 竖屏键盘（响应式网格、按键动画、触感、AC/C 逻辑）
- 2.3 横屏科学计算键盘 + ScientificFunctions 引擎
- 2.4 CalculatorViewModel 完整集成
- 2.5 计算历史（SwiftData 持久化、搜索、收藏、按日期分组）

### Phase 3: 工具框架
- 3.1 顶部工具栏（横向滚动 ToolChip、选中动画）
- 3.2 主容器 NumoTabView（表达式+工具栏+内容区域 + 切换过渡动画）
- 3.3 更多工具抽屉（底部 sheet、工具网格）
- 3.4 ToolModule 协议 + 工具注册表

### Phase 4: 各工具模块（按复杂度递增）
- 4.1 数字大写转换（最简单）
- 4.2 同比环比计算
- 4.3 单位换算
- 4.4 日期计算器
- 4.5 汇率换算（含网络请求）
- 4.6 贷款计算器
- 4.7 个税计算器（最复杂）

### Phase 5: 打磨
- 5.1 国际化（String Catalog 中英文全量翻译）
- 5.2 触感反馈审查与微调
- 5.3 动画打磨（工具切换、微交互、确保 60fps）
- 5.4 iPad 适配
- 5.5 无障碍（VoiceOver/Dynamic Type/对比度/减弱动态效果）
- 5.6 深色模式全面验证
- 5.7 边缘情况加固（超长表达式/快速连击/内存压力/旋转/前后台切换）

### Phase 6: 测试与上线准备
- 6.1 单元测试补全（引擎代码 >90% 覆盖率）
- 6.2 UI 自动化测试
- 6.3 性能分析（启动时间/内存/计算速度/滚动流畅度）
- 6.4 App Store 准备（图标/显示名/版本号/隐私描述/清理 entitlements）

---

## 8. 测试策略

### 单元测试（Swift Testing 框架，@Test 宏）
- ExpressionParser: 解析简单/复杂/边界表达式 ~10 个用例
- ExpressionEvaluator: 四则运算/优先级/括号/除零/百分比/科学函数/精度 ~12 个用例
- ChineseUppercaseConverter: 零/个位/十位/角分/内部零/万级/亿级 ~11 个用例
- ChineseTaxCalculator: 低于起征/不同税档/跨档/专项扣除/年度汇总 ~7 个用例
- LoanEngine: 等额本息/等额本金/零利率/单月/本金和校验 ~8 个用例
- WorkdayCalculator: 纯工作日/跳过节假日/调休补班/正向反向 ~6 个用例

### UI 测试（XCTest/XCUI）
- 计算器：输入表达式→验证结果、退格、清除
- 工具切换：切换 chip→验证 UI 变化→切回→状态保持
- 全工具 chip 可见可点击

### 验证方式
在每个 Phase 完成后：
1. `Cmd+B` 确保编译通过
2. 运行对应 Phase 的单元测试
3. 在模拟器上手动验证核心交互
4. Phase 5 后在真机上验证触感、动画流畅度

---

## 9. 关键文件（优先实现）

1. `calculator/calculatorApp.swift` — 入口重构，SwiftData schema + Environment
2. `calculator/Features/Calculator/Engine/ExpressionEvaluator.swift` — 数学核心
3. `calculator/App/AppState.swift` — 全局状态协调
4. `calculator/App/NumoTabView.swift` — UI 骨架
5. `calculator/DesignSystem/Theme/NumoColors.swift` — 所有视图的色彩基础
