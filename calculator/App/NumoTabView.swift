//
//  NumoTabView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import SwiftData

struct NumoTabView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    // MARK: - Persistent ViewModels

    @State private var calculatorVM = CalculatorViewModel()
    @State private var currencyVM = CurrencyExchangeViewModel()
    @State private var uppercaseVM = ChineseUppercaseViewModel()
    @State private var yoyVM = YoYCalculatorViewModel()

    @State private var dateVM = DateCalculatorViewModel()
    @State private var unitVM = UnitConverterViewModel()
    @State private var loanVM = LoanCalculatorViewModel()

    /// Active input field for multi-field tools
    @State private var activeField: ToolInputField = .primary
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var isKeypadCollapsed = false
    @State private var copyScale: CGFloat = 1.0
    @State private var isToastVisible = false
    @State private var isUnitPickerExpanded = false
    @State private var isDateModeExpanded   = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Top Bar (Tool Chips only)
                topBar
                    .padding(.top, NumoSpacing.xs)

                // MARK: - Morphing Display Area
                toolDisplay
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, NumoSpacing.md)
                    .scaleEffect(copyScale)
                    .onLongPressGesture(minimumDuration: 0.4) {
                        copyCurrentResult()
                    }

                // MARK: - Fixed Keypad
                if !isKeypadCollapsed {
                    KeypadView(
                        onCharacter: handleCharacter,
                        onOperator: handleOperator,
                        onDelete: handleDelete,
                        onClear: handleClear,
                        onPercent: handlePercent,
                        onEquals: handleEquals,
                        onUndo: handleUndo,
                        operatorOnRight: appState.operatorOnRight,
                        canUndo: calculatorVM.canUndo && appState.selectedTool == .calculator
                    )
                    .frame(height: 350)
                    .padding(.horizontal, NumoSpacing.sm)
                    .padding(.bottom, NumoSpacing.xxs)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isKeypadCollapsed = false
                        }
                    } label: {
                        HStack(spacing: NumoSpacing.xs) {
                            Image(systemName: "chevron.up")
                            Text(String(localized: "展开键盘"))
                                .font(NumoTypography.bodySmall)
                        }
                        .foregroundStyle(NumoColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(NumoColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, NumoSpacing.md)
                        .padding(.bottom, NumoSpacing.xs)
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(NumoColors.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if appState.selectedTool == .calculator {
                            showHistory = true
                        } else {
                            appState.selectTool(.calculator)
                        }
                    } label: {
                        Image(systemName: appState.selectedTool == .calculator ? "clock" : "chevron.backward")
                            .font(.system(size: 16, weight: .medium))
                            .contentTransition(.symbolEffect(.replace.downUp))
                            .animation(NumoAnimations.chipSelection, value: appState.selectedTool)
                    }
                }
                ToolbarItem(placement: .principal) {
                    principalArea
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
        .onChange(of: appState.selectedTool) { _, _ in
            activeField = .primary
            isUnitPickerExpanded = false
            isDateModeExpanded   = false
            if isKeypadCollapsed {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isKeypadCollapsed = false
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { appState.isAllToolsPanelOpen },
            set: { appState.isAllToolsPanelOpen = $0 }
        )) {
            AllToolsPanelView()
                .environment(appState)
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showHistory) {
            HistorySheetView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView()
                .environment(appState)
                .presentationDetents([.fraction(0.5), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - NavigationBar Principal (HUD + Toast 合层)

    // 不使用隐式 .animation(value:)，所有动画通过 withAnimation {} 显式驱动，
    // 避免动画上下文泄漏到 Menu label 导致收起时文字跳动。
    @ViewBuilder
    private var principalArea: some View {
        ZStack {
            // 底层：汇率 HUD / 单位 HUD（toast 显示时淡出）
            hudContent
                .opacity(isToastVisible ? 0 : 1)

            // 顶层：复制 Toast（无隐式 animation 修饰符）
            HStack(spacing: NumoSpacing.xs) {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                Text(String(localized: "结果已复制"))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, NumoSpacing.lg)
            .padding(.vertical, NumoSpacing.sm)
            .glassEffect(in: Capsule())
            .offset(y: isToastVisible ? 0 : -20)
            .scaleEffect(isToastVisible ? 1 : 0.75)
            .opacity(isToastVisible ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var hudContent: some View {
        switch appState.selectedTool {
        case .currency:
            VStack(spacing: 2) {
                Text(currencyVM.rateInfo.isEmpty ? "—" : currencyVM.rateInfo)
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
                    .foregroundStyle(NumoColors.textSecondary)
                    .contentTransition(.numericText())
                if let lastUpdated = currencyVM.lastUpdated {
                    Text(lastUpdated.relativeDescription)
                        .font(.system(size: 10).monospacedDigit())
                        .foregroundStyle(NumoColors.textTertiary)
                }
            }
            .multilineTextAlignment(.center)
            .transition(.push(from: .bottom).combined(with: .opacity))

        case .unit:
            ZStack {
                // ── 收起态：分类名 + chevron ──
                Button { isUnitPickerExpanded = true } label: {
                    HStack(spacing: 4) {
                        Text(unitVM.selectedCategory.displayName)
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(!isUnitPickerExpanded)
                .opacity(isUnitPickerExpanded ? 0 : 1)
                .scaleEffect(isUnitPickerExpanded ? 0.82 : 1)
                .blur(radius: isUnitPickerExpanded ? 3 : 0)
                .animation(
                    isUnitPickerExpanded
                        ? .spring(response: 0.22, dampingFraction: 0.90)           // 快速退场
                        : .spring(response: 0.44, dampingFraction: 0.82).delay(0.12), // 等选项收完再出现
                    value: isUnitPickerExpanded
                )

                // ── 展开态：6 等分布局 ──
                // HUD 区域宽度 = 屏幕宽 - 两侧按钮区域（各 44pt）
                // 5 个选项把 HUD 区域视觉 6 等分：[gap] item [gap] item [gap] item [gap] item [gap] item [gap]
                // 用 Spacer(minLength:0) 实现，6 个 Spacer 平分剩余空间，间距天然相等
                let hudWidth = UIScreen.main.bounds.width - 88
                HStack(spacing: 0) {
                    ForEach(Array(UnitCategory.allCases.enumerated()), id: \.element.id) { index, category in
                        let distance   = abs(index - 2)
                        let isSelected = unitVM.selectedCategory == category
                        let xDir: CGFloat = index < 2 ? 1 : (index > 2 ? -1 : 0)
                        let xMag: CGFloat = CGFloat(distance) * 8
                        let entryDelay = Double(distance) * 0.065
                        let exitDelay  = Double(2 - distance) * 0.055

                        Spacer(minLength: 0)

                        Button {
                            if !isSelected { unitVM.selectCategory(category) }
                            isUnitPickerExpanded = false
                        } label: {
                            Text(category.displayName)
                                .font(.system(size: 15,
                                              weight: isSelected ? .semibold : .regular,
                                              design: .rounded))
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(isUnitPickerExpanded)
                        .opacity(isUnitPickerExpanded ? 1 : 0)
                        .scaleEffect(isUnitPickerExpanded ? 1 : 0.62)
                        .offset(x: isUnitPickerExpanded ? 0 : xDir * xMag,
                                y: isUnitPickerExpanded ? 0 : 6)
                        .animation(
                            isUnitPickerExpanded
                                ? .spring(response: 0.52, dampingFraction: 0.68).delay(entryDelay)
                                : .spring(response: 0.26, dampingFraction: 0.90).delay(exitDelay),
                            value: isUnitPickerExpanded
                        )
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: hudWidth)  // HUD 区域固定宽度，撑开 titleView
            }
            .transition(.opacity)

        case .yoy:
            Group {
                if yoyVM.yoyResult != nil || yoyVM.momResult != nil {
                    VStack(spacing: 1) {
                        if let yoy = yoyVM.yoyResult {
                            let word = yoy.trend == .up ? "增长" : yoy.trend == .down ? "下跌" : "持平"
                            let arrow = yoy.trend == .up ? "↑" : yoy.trend == .down ? "↓" : "→"
                            HStack(spacing: 3) {
                                Text("同比").foregroundStyle(NumoColors.textSecondary)
                                Text("\(word) \(ExpressionFormatter.formatPercent(yoy.percentageChange)) \(arrow)")
                                    .foregroundStyle(yoy.trend.color)
                                    .contentTransition(.numericText())
                            }
                        }
                        if let mom = yoyVM.momResult {
                            let word = mom.trend == .up ? "增长" : mom.trend == .down ? "下跌" : "持平"
                            let arrow = mom.trend == .up ? "↑" : mom.trend == .down ? "↓" : "→"
                            HStack(spacing: 3) {
                                Text("环比").foregroundStyle(NumoColors.textSecondary)
                                Text("\(word) \(ExpressionFormatter.formatPercent(mom.percentageChange)) \(arrow)")
                                    .foregroundStyle(mom.trend.color)
                                    .contentTransition(.numericText())
                            }
                        }
                    }
                    .transition(.push(from: .bottom).combined(with: .opacity))
                } else {
                    Text("数据对比分析")
                        .foregroundStyle(NumoColors.textSecondary)
                        .transition(.push(from: .top).combined(with: .opacity))
                }
            }
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .animation(.easeInOut(duration: 0.2), value: yoyVM.yoyResult?.percentageChange)
            .animation(.easeInOut(duration: 0.2), value: yoyVM.momResult?.percentageChange)
            .transition(.push(from: .bottom).combined(with: .opacity))

        case .uppercase:
            let digitCount = uppercaseVM.inputAmount.filter { $0.isNumber }.count
            Text(uppercaseVM.inputAmount.isEmpty ? "输入金额" : "共 \(digitCount) 位数字")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(NumoColors.textSecondary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.18), value: uppercaseVM.inputAmount)
                .transition(.push(from: .bottom).combined(with: .opacity))

        case .loan:
            Button { loanVM.showSchedule = true } label: {
                HStack(spacing: 4) {
                    Text("还款明细")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.secondary.opacity(0.45))
                }
                .foregroundStyle(loanVM.result != nil ? Color.primary : Color.secondary.opacity(0.35))
            }
            .buttonStyle(.plain)
            .disabled(loanVM.result == nil)
            .transition(.push(from: .bottom).combined(with: .opacity))

        case .date:
            ZStack {
                // ── 收起态：当前模式名 + chevron ──
                Button { isDateModeExpanded = true } label: {
                    HStack(spacing: 4) {
                        Text(dateModeName(dateVM.mode))
                            .font(.subheadline.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .allowsHitTesting(!isDateModeExpanded)
                .opacity(isDateModeExpanded ? 0 : 1)
                .scaleEffect(isDateModeExpanded ? 0.82 : 1)
                .blur(radius: isDateModeExpanded ? 3 : 0)
                .animation(
                    isDateModeExpanded
                        ? .spring(response: 0.22, dampingFraction: 0.90)
                        : .spring(response: 0.44, dampingFraction: 0.82).delay(0.12),
                    value: isDateModeExpanded
                )

                // ── 展开态：3 个模式等分 ──
                let hudWidth = UIScreen.main.bounds.width - 88
                HStack(spacing: 0) {
                    ForEach(Array(DateCalcMode.allCases.enumerated()), id: \.offset) { index, mode in
                        let distance   = abs(index - 1)
                        let isSelected = dateVM.mode == mode
                        let xDir: CGFloat = index < 1 ? 1 : (index > 1 ? -1 : 0)
                        let xMag: CGFloat = CGFloat(distance) * 10
                        let entryDelay = Double(distance) * 0.065
                        let exitDelay  = Double(1 - distance) * 0.055

                        Spacer(minLength: 0)

                        Button {
                            if !isSelected { dateVM.mode = mode }
                            isDateModeExpanded = false
                        } label: {
                            Text(dateModeName(mode))
                                .font(.system(size: 15,
                                              weight: isSelected ? .semibold : .regular,
                                              design: .rounded))
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(isDateModeExpanded)
                        .opacity(isDateModeExpanded ? 1 : 0)
                        .scaleEffect(isDateModeExpanded ? 1 : 0.62)
                        .offset(x: isDateModeExpanded ? 0 : xDir * xMag,
                                y: isDateModeExpanded ? 0 : 6)
                        .animation(
                            isDateModeExpanded
                                ? .spring(response: 0.52, dampingFraction: 0.68).delay(entryDelay)
                                : .spring(response: 0.26, dampingFraction: 0.90).delay(exitDelay),
                            value: isDateModeExpanded
                        )
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: hudWidth)
            }
            .transition(.opacity)

        default:
            Color.clear
                .frame(width: 1, height: 1)
                .transition(.push(from: .top).combined(with: .opacity))
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NumoSpacing.chipGap) {
                ForEach(appState.favoriteTools.filter { $0 != .calculator }) { tool in
                    ToolChip(tool: tool, isSelected: appState.selectedTool == tool) {
                        appState.selectTool(tool)
                    }
                }

                // Show a temporary chip if selected tool is not in favorites (and not calculator)
                if appState.selectedTool != .calculator && !appState.isFavorite(appState.selectedTool) {
                    ToolChip(tool: appState.selectedTool, isSelected: true) {
                        // Already selected — no-op
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // "+" button to open all tools panel
                Button {
                    appState.isAllToolsPanelOpen = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(NumoColors.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(NumoColors.chipDefault)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, NumoSpacing.sm)
            .animation(NumoAnimations.interactiveSpring, value: appState.favoriteTools)
            .animation(NumoAnimations.interactiveSpring, value: appState.selectedTool)
        }
    }

    // MARK: - Morphing Display

    @ViewBuilder
    private var toolDisplay: some View {
        Group {
            switch appState.selectedTool {
            case .calculator:
                CalculatorView(viewModel: calculatorVM)
            case .currency:
                CurrencyExchangeView(viewModel: currencyVM)
            case .uppercase:
                ChineseUppercaseView(viewModel: uppercaseVM)
            case .yoy:
                YoYCalculatorView(viewModel: yoyVM, activeField: $activeField)

            case .date:
                DateCalculatorView(viewModel: dateVM)
            case .unit:
                UnitConverterView(viewModel: unitVM)
            case .loan:
                LoanCalculatorView(viewModel: loanVM, activeField: $activeField, onScrollCollapse: collapseKeypad)
            }
        }
        .transition(.toolSwitch)
        .id(appState.selectedTool)
    }

    // MARK: - Input Routing

    private func handleCharacter(_ char: String) {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.appendCharacter(char)
        case .currency:
            appendDigit(to: &currencyVM.sourceAmount, char: char)
            currencyVM.convert()
        case .uppercase:
            appendDigit(to: &uppercaseVM.inputAmount, char: char)
            uppercaseVM.convert()
        case .yoy:
            switch activeField {
            case .primary:
                appendDigit(to: &yoyVM.currentValueText, char: char)
            case .secondary:
                appendDigit(to: &yoyVM.yoyPreviousText, char: char)
            case .tertiary:
                appendDigit(to: &yoyVM.momPreviousText, char: char)
            }
            yoyVM.calculate()

        case .date:
            switch dateVM.mode {
            case .difference:
                break
            case .offset:
                appendDigit(to: &dateVM.offsetDays, char: char)
                dateVM.calculateOffset()
            case .workday:
                appendDigit(to: &dateVM.workdayCount, char: char)
                dateVM.calculateWorkday()
            }
        case .unit:
            appendDigit(to: &unitVM.sourceValue, char: char)
            unitVM.convert()
        case .loan:
            switch activeField {
            case .primary:
                appendDigit(to: &loanVM.amountText, char: char)
            case .secondary:
                appendDigit(to: &loanVM.annualRateText, char: char)
            case .tertiary:
                guard char != ".", char != "00" else { return }
                let proposed = loanVM.termYearText + char
                if let year = Int(proposed), year >= 1, year <= 30 {
                    loanVM.termYearText = proposed
                    loanVM.termMonths = year * 12
                } else if Int(proposed) ?? 0 > 30 {
                    // Start fresh with this single digit if valid
                    if let y = Int(char), y >= 1 {
                        loanVM.termYearText = char
                        loanVM.termMonths = y * 12
                    }
                }
            default: break
            }
            loanVM.calculate()
        }
    }

    private func handleOperator(_ op: String) {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.appendOperator(op)
        default:
            break
        }
    }

    private func handleDelete() {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.deleteBackward()
        case .currency:
            deleteLastDigit(from: &currencyVM.sourceAmount)
            currencyVM.convert()
        case .uppercase:
            deleteLastDigit(from: &uppercaseVM.inputAmount)
            uppercaseVM.convert()
        case .yoy:
            switch activeField {
            case .primary:
                deleteLastDigit(from: &yoyVM.currentValueText)
            case .secondary:
                deleteLastDigit(from: &yoyVM.yoyPreviousText)
            case .tertiary:
                deleteLastDigit(from: &yoyVM.momPreviousText)
            }
            yoyVM.calculate()

        case .date:
            switch dateVM.mode {
            case .difference:
                break
            case .offset:
                deleteLastDigit(from: &dateVM.offsetDays)
                dateVM.calculateOffset()
            case .workday:
                deleteLastDigit(from: &dateVM.workdayCount)
                dateVM.calculateWorkday()
            }
        case .unit:
            deleteLastDigit(from: &unitVM.sourceValue)
            unitVM.convert()
        case .loan:
            switch activeField {
            case .primary:
                deleteLastDigit(from: &loanVM.amountText)
            case .secondary:
                deleteLastDigit(from: &loanVM.annualRateText)
            case .tertiary:
                if loanVM.termYearText.count > 1 {
                    loanVM.termYearText.removeLast()
                } else {
                    loanVM.termYearText = "1"
                }
                loanVM.termMonths = (Int(loanVM.termYearText) ?? 1) * 12
            default: break
            }
            loanVM.calculate()
        }
    }

    private func handleClear() {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.clear()
        case .currency:
            currencyVM.sourceAmount = ""
            currencyVM.convert()
        case .uppercase:
            uppercaseVM.inputAmount = ""
            uppercaseVM.convert()
        case .yoy:
            switch activeField {
            case .primary:
                yoyVM.currentValueText = ""
            case .secondary:
                yoyVM.yoyPreviousText = ""
            case .tertiary:
                yoyVM.momPreviousText = ""
            }
            yoyVM.calculate()

        case .date:
            switch dateVM.mode {
            case .difference:
                break
            case .offset:
                dateVM.offsetDays = ""
                dateVM.calculateOffset()
            case .workday:
                dateVM.workdayCount = ""
                dateVM.calculateWorkday()
            }
        case .unit:
            unitVM.sourceValue = ""
            unitVM.convert()
        case .loan:
            switch activeField {
            case .primary:
                loanVM.amountText = ""
            case .secondary:
                loanVM.annualRateText = ""
            case .tertiary:
                loanVM.termYearText = "30"
                loanVM.termMonths = 360
            default: break
            }
            loanVM.calculate()
        }
    }

    private func handlePercent() {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.applyPercent()
        default:
            break
        }
    }

    private func handleEquals() {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.calculateAndCommit(modelContext: modelContext, appState: appState)
        case .currency:
            currencyVM.convert()
        case .uppercase:
            uppercaseVM.convert()
        case .yoy:
            yoyVM.calculate()

        case .date:
            switch dateVM.mode {
            case .difference:
                dateVM.calculateDifference()
            case .offset:
                dateVM.calculateOffset()
            case .workday:
                dateVM.calculateWorkday()
            }
        case .unit:
            unitVM.convert()
        case .loan:
            loanVM.calculate()
        }
    }

    private func handleUndo() {
        switch appState.selectedTool {
        case .calculator:
            calculatorVM.undo()
        default:
            // For other tools, undo clears the active field
            handleClear()
        }
    }

    // MARK: - Copy Result

    private var currentCopyableResult: String? {
        switch appState.selectedTool {
        case .calculator:
            let r = calculatorVM.currentResult
            return r.isEmpty ? nil : r
        case .currency:
            let r = currencyVM.convertedAmount
            return r.isEmpty ? nil : r
        case .uppercase:
            let r = uppercaseVM.uppercaseResult
            return r.isEmpty ? nil : r
        case .yoy:
            guard let r = yoyVM.yoyResult else { return nil }
            return ExpressionFormatter.formatSigned(r.percentageChange) + "%"

        case .date:
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            switch dateVM.mode {
            case .difference:
                guard let r = dateVM.differenceResult else { return nil }
                return "\(r.days) 天"
            case .offset:
                guard let d = dateVM.offsetResult else { return nil }
                return fmt.string(from: d)
            case .workday:
                guard let d = dateVM.workdayResult else { return nil }
                return fmt.string(from: d)
            }
        case .unit:
            let r = unitVM.convertedValue
            return r.isEmpty ? nil : r
        case .loan:
            guard let r = loanVM.result else { return nil }
            return ExpressionFormatter.formatCurrency(r.monthlyPayment)
        }
    }

    private func copyCurrentResult() {
        guard let text = currentCopyableResult else { return }
        UIPasteboard.general.string = text
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // 按下感：快速压缩到 96%
        withAnimation(.spring(response: 0.18, dampingFraction: 0.85)) { copyScale = 0.96 }
        // 回弹：欠阻尼弹簧，轻微过冲后归位
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
            withAnimation(.spring(response: 0.48, dampingFraction: 0.52)) { copyScale = 1.0 }
        }

        // Toast 显示/隐藏：用显式 withAnimation 驱动，不污染全局动画上下文
        withAnimation(.spring(response: 0.36, dampingFraction: 0.68)) {
            isToastVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                isToastVisible = false
            }
        }
    }

    private func collapseKeypad() {
        guard !isKeypadCollapsed else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isKeypadCollapsed = true
        }
    }

    // MARK: - Helpers

    private func appendDigit(to value: inout String, char: String) {
        if char == "." && value.contains(".") { return }
        if char == "00" && value.isEmpty { value = "0"; return }
        if value == "0" && char != "." && char != "00" { value = char; return }
        value.append(char)
    }

    private func deleteLastDigit(from value: inout String) {
        if !value.isEmpty { value.removeLast() }
    }

    private func dateModeName(_ mode: DateCalcMode) -> String {
        switch mode {
        case .difference: return "日期间隔"
        case .offset:     return "日期推算"
        case .workday:    return "工作日"
        }
    }
}

// MARK: - History Sheet

struct HistorySheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CalculationRecord.timestamp, order: .reverse) private var records: [CalculationRecord]

    @State private var isEditing = false
    @State private var selectedIDs: Set<PersistentIdentifier> = []

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    VStack(spacing: NumoSpacing.md) {
                        Image(systemName: "clock")
                            .font(.system(size: 40))
                            .foregroundStyle(NumoColors.textTertiary)
                        Text(String(localized: "暂无计算记录"))
                            .font(NumoTypography.bodyMedium)
                            .foregroundStyle(NumoColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: isEditing ? $selectedIDs : nil) {
                        ForEach(groupedSections, id: \.title) { section in
                            Section {
                                ForEach(section.records) { record in
                                    VStack(alignment: .trailing, spacing: NumoSpacing.xxs) {
                                        Text(record.expression)
                                            .font(NumoTypography.bodySmall)
                                            .foregroundStyle(NumoColors.textSecondary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        Text("= \(record.result)")
                                            .font(NumoTypography.monoTitleLarge)
                                            .foregroundStyle(NumoColors.textPrimary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                        Text(record.timestamp.relativeDescription)
                                            .font(NumoTypography.caption)
                                            .foregroundStyle(NumoColors.textTertiary)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .padding(.vertical, NumoSpacing.xxs)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(record)
                                        } label: {
                                            Label(String(localized: "删除"), systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            UIPasteboard.general.string = record.result
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        } label: {
                                            Label(String(localized: "复制"), systemImage: "doc.on.doc")
                                        }
                                        .tint(Color(uiColor: .systemGray2))
                                    }
                                }
                            } header: {
                                Text(section.title)
                                    .font(NumoTypography.bodySmall.weight(.medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(isEditing ? .active : .inactive))
                }
            }
            .navigationTitle(String(localized: "计算历史"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !records.isEmpty {
                        Button(isEditing ? String(localized: "完成") : String(localized: "编辑")) {
                            withAnimation {
                                isEditing.toggle()
                                if !isEditing { selectedIDs.removeAll() }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button(String(localized: "全部清除"), role: .destructive) {
                            deleteAll()
                        }
                        .foregroundStyle(NumoColors.danger)
                    } else {
                        Button(String(localized: "关闭")) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if isEditing && !selectedIDs.isEmpty {
                        Button(String(localized: "删除选中 (\(selectedIDs.count))"), role: .destructive) {
                            deleteSelected()
                        }
                        .foregroundStyle(NumoColors.danger)
                    }
                }
            }
        }
    }

    // MARK: - Date Grouping

    private struct HistorySection {
        let title: String
        let records: [CalculationRecord]
    }

    private var groupedSections: [HistorySection] {
        let calendar = Calendar.current
        let now = Date.now

        var recent7: [CalculationRecord] = []
        var recent30: [CalculationRecord] = []
        var older: [CalculationRecord] = []

        for record in records {
            let days = calendar.dateComponents([.day], from: record.timestamp, to: now).day ?? 0
            if days < 7 {
                recent7.append(record)
            } else if days < 30 {
                recent30.append(record)
            } else {
                older.append(record)
            }
        }

        var sections: [HistorySection] = []
        if !recent7.isEmpty { sections.append(HistorySection(title: String(localized: "过去 7 天"), records: recent7)) }
        if !recent30.isEmpty { sections.append(HistorySection(title: String(localized: "过去 30 天"), records: recent30)) }
        if !older.isEmpty { sections.append(HistorySection(title: String(localized: "更早"), records: older)) }
        return sections
    }

    // MARK: - Actions

    private func deleteSelected() {
        for record in records where selectedIDs.contains(record.persistentModelID) {
            modelContext.delete(record)
        }
        selectedIDs.removeAll()
    }

    private func deleteAll() {
        for record in records {
            modelContext.delete(record)
        }
        isEditing = false
        selectedIDs.removeAll()
    }
}

// MARK: - Settings Sheet

struct SettingsSheetView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            List {
                // MARK: Favorites Management
                Section {
                    ForEach(appState.favoriteTools) { tool in
                        HStack(spacing: NumoSpacing.sm) {
                            Image(systemName: tool.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(NumoColors.textSecondary)
                                .frame(width: 24)
                            Text(tool.displayName)
                                .font(NumoTypography.bodyMedium)
                            Spacer()
                            if appState.favoriteTools.count > 1 {
                                Button {
                                    withAnimation {
                                        appState.toggleFavorite(tool)
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(NumoColors.danger)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .onMove { source, destination in
                        appState.moveFavorite(from: source, to: destination)
                    }
                } header: {
                    Text(String(localized: "快捷工具"))
                } footer: {
                    Text(String(localized: "长按拖动可调整顺序"))
                }

                // MARK: Keyboard Layout
                Section {
                    @Bindable var state = appState
                    HStack {
                        Label(String(localized: "运算符位置"), systemImage: "keyboard")
                        Spacer()
                        Picker("", selection: $state.operatorOnRight) {
                            Text(String(localized: "左侧")).tag(false)
                            Text(String(localized: "右侧")).tag(true)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                    }
                } header: {
                    Text(String(localized: "键盘布局"))
                }
            }
            .navigationTitle(String(localized: "设置"))
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.editMode, .constant(.active))
        }
    }
}


#Preview {
    NumoTabView()
        .environment(AppState())
        .environment(HapticService())
}
