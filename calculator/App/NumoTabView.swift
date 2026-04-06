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

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Bar (History + Tool Toolbar)
            topBar
                .padding(.top, NumoSpacing.xs)

            // MARK: - Morphing Display Area
            toolDisplay
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, NumoSpacing.md)
                .onLongPressGesture {
                    pasteFromClipboard()
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
                    onAns: handleAns,
                    operatorOnRight: appState.operatorOnRight
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
        .onChange(of: appState.selectedTool) { _, _ in
            activeField = .primary
        }
        .sheet(isPresented: Binding(
            get: { appState.isDrawerOpen },
            set: { appState.isDrawerOpen = $0 }
        )) {
            ToolDrawerView()
                .environment(appState)
                .presentationDetents([.fraction(0.4), .large])
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
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 0) {
            // History button
            Button {
                showHistory = true
            } label: {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(NumoColors.textSecondary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .padding(.leading, NumoSpacing.sm)

            // Tool chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NumoSpacing.chipGap) {
                    ForEach(Tool.allCases) { tool in
                        if Tool.toolbarTools.contains(tool) {
                            ToolChip(tool: tool, isSelected: appState.selectedTool == tool) {
                                appState.selectTool(tool)
                            }
                        }
                    }

                    // More button
                    Button {
                        appState.isDrawerOpen = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(NumoTypography.bodyMedium)
                            .foregroundStyle(NumoColors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(NumoColors.chipDefault)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, NumoSpacing.xs)
            }

            // Settings button
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(NumoColors.textSecondary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .padding(.trailing, NumoSpacing.sm)
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
                IncomeTaxView(viewModel: incomeTaxVM, activeField: $activeField)
            case .date:
                DateCalculatorView(viewModel: dateVM)
            case .unit:
                UnitConverterView(viewModel: unitVM)
            case .loan:
                LoanCalculatorView(viewModel: loanVM, activeField: $activeField)
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

    private func pasteFromClipboard() {
        guard let clipString = UIPasteboard.general.string else { return }
        // Extract numeric portion (digits, dots, minus)
        let cleaned = clipString.filter { $0.isNumber || $0 == "." || $0 == "-" }
        guard !cleaned.isEmpty else { return }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        switch appState.selectedTool {
        case .calculator:
            calculatorVM.appendCharacter(cleaned)
        case .currency:
            currencyVM.sourceAmount = cleaned
            currencyVM.convert()
        case .uppercase:
            uppercaseVM.inputAmount = cleaned
            uppercaseVM.convert()
        case .yoy:
            switch activeField {
            case .primary: yoyVM.currentValueText = cleaned
            case .secondary: yoyVM.yoyPreviousText = cleaned
            case .tertiary: yoyVM.momPreviousText = cleaned
            }
            yoyVM.calculate()
        case .incomeTax:
            switch activeField {
            case .primary: incomeTaxVM.monthlySalaryText = cleaned
            case .secondary: incomeTaxVM.specialDeductionsText = cleaned
            default: break
            }
            incomeTaxVM.calculate()
        case .date:
            switch dateVM.mode {
            case .difference: break
            case .offset:
                dateVM.offsetDays = cleaned
                dateVM.calculateOffset()
            case .workday:
                dateVM.workdayCount = cleaned
                dateVM.calculateWorkday()
            }
        case .unit:
            unitVM.sourceValue = cleaned
            unitVM.convert()
        case .loan:
            switch activeField {
            case .primary: loanVM.amountText = cleaned
            case .secondary: loanVM.annualRateText = cleaned
            default: break
            }
            loanVM.calculate()
        }
    }

    private func handleAns() {
        guard let lastResult = appState.lastResult else { return }
        let resultString = ExpressionFormatter.format(lastResult).withoutGroupingSeparators

        switch appState.selectedTool {
        case .calculator:
            calculatorVM.appendCharacter(resultString)
        case .currency:
            currencyVM.sourceAmount = resultString
            currencyVM.convert()
        case .uppercase:
            uppercaseVM.inputAmount = resultString
            uppercaseVM.convert()
        case .yoy:
            switch activeField {
            case .primary:
                yoyVM.currentValueText = resultString
            case .secondary:
                yoyVM.yoyPreviousText = resultString
            case .tertiary:
                yoyVM.momPreviousText = resultString
            }
            yoyVM.calculate()
        case .incomeTax:
            switch activeField {
            case .primary:
                incomeTaxVM.monthlySalaryText = resultString
            case .secondary:
                incomeTaxVM.specialDeductionsText = resultString
            default: break
            }
            incomeTaxVM.calculate()
        case .date:
            switch dateVM.mode {
            case .difference: break
            case .offset:
                dateVM.offsetDays = resultString
                dateVM.calculateOffset()
            case .workday:
                dateVM.workdayCount = resultString
                dateVM.calculateWorkday()
            }
        case .unit:
            unitVM.sourceValue = resultString
            unitVM.convert()
        case .loan:
            switch activeField {
            case .primary:
                loanVM.amountText = resultString
            case .secondary:
                loanVM.annualRateText = resultString
            default: break
            }
            loanVM.calculate()
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
                                    .listRowBackground(NumoColors.surface)
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
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(NumoColors.textSecondary)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(NumoColors.surfaceSecondary))
                        }
                        .buttonStyle(.plain)
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

// MARK: - Tool Drawer

struct ToolDrawerView: View {
    @Environment(AppState.self) private var appState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: NumoSpacing.md) {
                    ForEach(Tool.allCases) { tool in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                            appState.selectTool(tool)
                        } label: {
                            VStack(spacing: NumoSpacing.xs) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(
                                        appState.selectedTool == tool
                                            ? NumoColors.chipSelected
                                            : NumoColors.textSecondary
                                    )
                                Text(tool.displayName)
                                    .font(NumoTypography.bodyMedium)
                                    .foregroundStyle(NumoColors.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, NumoSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(NumoColors.surfaceSecondary)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(NumoSpacing.md)
            }
            .navigationTitle(String(localized: "全部工具"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Settings Sheet

struct SettingsSheetView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            List {
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
        }
    }
}

#Preview {
    NumoTabView()
        .environment(AppState())
        .environment(HapticService())
}
