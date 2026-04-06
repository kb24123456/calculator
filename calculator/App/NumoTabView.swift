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
    @State private var incomeTaxVM = IncomeTaxViewModel()
    @State private var dateVM = DateCalculatorViewModel()
    @State private var unitVM = UnitConverterViewModel()
    @State private var loanVM = LoanCalculatorViewModel()

    /// Active input field for multi-field tools
    @State private var activeField: ToolInputField = .primary
    @State private var showHistory = false
    @State private var showSettings = false
    @State private var isKeypadCollapsed = false
    @State private var isResultHighlighted = false
    @State private var isToastVisible = false

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
                    .onLongPressGesture(minimumDuration: 0.4) {
                        copyCurrentResult()
                    }
                    .overlay(
                        Color.blue
                            .opacity(isResultHighlighted ? 0.13 : 0)
                            .blur(radius: 18)
                            .allowsHitTesting(false)
                            .animation(.easeOut(duration: 0.12), value: isResultHighlighted)
                    )

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

    // Toast 直接在 toolbar 里渲染，天然和两侧按钮垂直居中，无需任何坐标计算
    @ViewBuilder
    private var principalArea: some View {
        ZStack {
            // 底层：汇率 HUD（仅汇率页可见）
            hudContent
                .opacity(isToastVisible ? 0 : 1)
                .animation(.easeOut(duration: 0.12), value: isToastVisible)

            // 顶层：复制 Toast
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
            // offset + scale + opacity: 纯 GPU 变换，跑满 120Hz
            .offset(y: isToastVisible ? 0 : -20)
            .scaleEffect(isToastVisible ? 1 : 0.75)
            .opacity(isToastVisible ? 1 : 0)
            .animation(
                isToastVisible
                    ? .spring(response: 0.36, dampingFraction: 0.68)
                    : .spring(response: 0.24, dampingFraction: 0.86),
                value: isToastVisible
            )
        }
    }

    @ViewBuilder
    private var hudContent: some View {
        switch appState.selectedTool {
        case .currency:
            VStack(spacing: 2) {
                Text(currencyVM.rateInfo.isEmpty ? "—" : currencyVM.rateInfo)
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
                    .foregroundStyle(NumoColors.textSecondary)
                if let lastUpdated = currencyVM.lastUpdated {
                    Text(lastUpdated.relativeDescription)
                        .font(.system(size: 10).monospacedDigit())
                        .foregroundStyle(NumoColors.textTertiary)
                }
            }
            .multilineTextAlignment(.center)
            .transition(.push(from: .bottom).combined(with: .opacity))
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
            case .incomeTax:
                IncomeTaxView(viewModel: incomeTaxVM, activeField: $activeField, onScrollCollapse: collapseKeypad)
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
        case .incomeTax:
            switch activeField {
            case .primary:
                appendDigit(to: &incomeTaxVM.monthlySalaryText, char: char)
            case .secondary:
                appendDigit(to: &incomeTaxVM.specialDeductionsText, char: char)
            default: break
            }
            incomeTaxVM.calculate()
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
        case .incomeTax:
            switch activeField {
            case .primary:
                deleteLastDigit(from: &incomeTaxVM.monthlySalaryText)
            case .secondary:
                deleteLastDigit(from: &incomeTaxVM.specialDeductionsText)
            default: break
            }
            incomeTaxVM.calculate()
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
        case .incomeTax:
            switch activeField {
            case .primary:
                incomeTaxVM.monthlySalaryText = ""
            case .secondary:
                incomeTaxVM.specialDeductionsText = ""
            default: break
            }
            incomeTaxVM.calculate()
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
        case .incomeTax:
            incomeTaxVM.calculate()
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
        case .incomeTax:
            guard let r = incomeTaxVM.result, let net = r.monthlyNetSalary.first else { return nil }
            return ExpressionFormatter.formatCurrency(net)
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

        // Brief highlight flash
        withAnimation(.easeOut(duration: 0.08)) { isResultHighlighted = true }
        withAnimation(.easeIn(duration: 0.25).delay(0.12)) { isResultHighlighted = false }

        // Glass toast
        isToastVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            isToastVisible = false
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
