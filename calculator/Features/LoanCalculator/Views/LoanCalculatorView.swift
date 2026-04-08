//
//  LoanCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import UIKit

// MARK: - Main View

struct LoanCalculatorView: View {
    let viewModel: LoanCalculatorViewModel
    @Binding var activeField: ToolInputField
    var onScrollCollapse: (() -> Void)?  // unused

    // ── Slide state ──
    @State private var contentIsHero = false
    @State private var heroDragX: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            // heroX: 0 = fully on screen, w = off-screen right
            let heroX: CGFloat = contentIsHero ? heroDragX : w
            // inputX: slight parallax — slides slightly left when hero covers it
            let inputX: CGFloat = -(w * 0.25) * (1 - heroX / w)

            ZStack(alignment: .leading) {
                inputPage
                    .offset(x: inputX)

                heroPage
                    .offset(x: heroX)
                    .contentShape(Rectangle())
                    .allowsHitTesting(contentIsHero)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                guard contentIsHero else { return }
                                heroDragX = max(0, value.translation.width)
                            }
                            .onEnded { value in
                                guard contentIsHero else { return }
                                if value.translation.width > w * 0.3
                                    || value.velocity.width > 500 {
                                    slideToInput()
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        heroDragX = 0
                                    }
                                }
                            }
                    )
            }
            .clipped()
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showSchedule },
            set: { viewModel.showSchedule = $0 }
        )) {
            if let result = viewModel.result {
                RepaymentScheduleSheet(result: result, method: viewModel.method)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Input Page

    private var inputPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                inputCard
                flipEntryRow
            }
            .padding(.top, NumoSpacing.xs)
            .padding(.bottom, NumoSpacing.xs)
        }
    }

    // MARK: - Hero Page

    private var heroPage: some View {
        ScrollView(showsIndicators: false) {
            if let result = viewModel.result {
                VStack(spacing: 10) {
                    // ── Back capsule ──
                    Button { slideToInput() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 10, weight: .semibold))
                            Text("修改参数")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(Capsule().fill(Color(uiColor: .secondarySystemBackground)))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // ── Hero card: monthly payment ──
                    VStack(spacing: 8) {
                        Text(heroLabel)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondary)

                        Text(ExpressionFormatter.formatCurrency(result.monthlyPayment))
                            .font(.system(size: 44, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.monthlyPayment)

                        if let last = result.lastMonthPayment {
                            Text("末月 \(ExpressionFormatter.formatCurrency(last))")
                                .font(.system(size: 12).monospacedDigit())
                                .foregroundStyle(Color.secondary.opacity(0.50))
                                .contentTransition(.numericText())
                        }
                    }
                    .padding(.horizontal, NumoSpacing.md)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )

                    // ── Breakdown card: 总还款 / 总利息 ──
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("总还款")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.secondary.opacity(0.55))
                            Text(ExpressionFormatter.formatCurrency(result.totalRepayment))
                                .font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                                .foregroundStyle(Color.primary)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.totalRepayment)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("总利息")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Color.secondary.opacity(0.55))
                            Text(ExpressionFormatter.formatCurrency(result.totalInterest))
                                .font(.system(size: 17, weight: .semibold, design: .rounded).monospacedDigit())
                                .foregroundStyle(NumoColors.danger)
                                .contentTransition(.numericText())
                                .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.totalInterest)
                        }
                    }
                    .padding(.horizontal, NumoSpacing.md)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )

                    // ── 还款明细 capsule ──
                    Button {
                        viewModel.showSchedule = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("还款明细")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Color.primary)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(Capsule().fill(Color(uiColor: .secondarySystemBackground)))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.top, NumoSpacing.xs)
                .padding(.bottom, NumoSpacing.xs)
            } else {
                VStack {
                    Spacer(minLength: 100)
                    Text("请先输入贷款金额")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: viewModel.result?.monthlyPayment)
    }

    // MARK: - Flip Entry Row — capsule showing monthly payment

    private var flipEntryRow: some View {
        let hasResult = viewModel.result != nil
        return Button {
            if hasResult { slideToHero() }
        } label: {
            HStack(spacing: 6) {
                if let result = viewModel.result {
                    Text(heroLabel)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                    Text(ExpressionFormatter.formatCurrency(result.monthlyPayment))
                        .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.monthlyPayment)
                } else {
                    Text("输入贷款金额后查看月供")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.40))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary.opacity(hasResult ? 0.40 : 0.18))
            }
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(Capsule().fill(Color(uiColor: .secondarySystemBackground)))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .animation(.easeInOut(duration: 0.15), value: hasResult)
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── 贷款金额 ──
            amountRow
                .padding(.horizontal, NumoSpacing.md)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .contentShape(Rectangle())
                .onTapGesture { activeField = .primary }

            Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)

            // ── 贷款期限 ──
            termRow
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 14)

            Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)

            // ── 年利率 ──
            rateRow
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
                .onTapGesture { activeField = .secondary }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .animation(.easeInOut(duration: 0.15), value: activeField)
    }

    // ── Amount row
    private var amountRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("贷款金额")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(activeField == .primary ? Color.secondary : Color.secondary.opacity(0.55))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Spacer(minLength: 0)
                CursorTextField(
                    text: viewModel.amountText,
                    placeholder: "0",
                    uiFont: .systemFont(ofSize: 40, weight: .bold).rounded,
                    isFocused: activeField == .primary && !contentIsHero,
                    onTap: { activeField = .primary }
                )
                .frame(height: 46)
                .frame(maxWidth: .infinity)

                Text("万")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary.opacity(0.40))
                    .padding(.bottom, 2)
            }
        }
    }

    // ── Term row (Menu dropdown, 1–30 years)
    private var termRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("贷款期限")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary.opacity(0.55))

            HStack {
                Spacer()
                Menu {
                    ForEach(LoanCalculatorViewModel.termPresets, id: \.months) { preset in
                        Button {
                            viewModel.termMonths = preset.months
                            viewModel.calculate()
                        } label: {
                            if viewModel.termMonths == preset.months {
                                Label(preset.label, systemImage: "checkmark")
                            } else {
                                Text(preset.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(currentTermLabel)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Capsule().fill(Color(uiColor: .systemGray5)))
                }
            }
        }
    }

    private var currentTermLabel: String {
        LoanCalculatorViewModel.termPresets
            .first { $0.months == viewModel.termMonths }?
            .label ?? "\(viewModel.termMonths / 12) 年"
    }

    // ── Rate row (capsule chips + text field)
    private var rateRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("年利率")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(activeField == .secondary ? Color.secondary : Color.secondary.opacity(0.55))

                HStack(spacing: 6) {
                    ForEach(LoanCalculatorViewModel.ratePresets, id: \.rate) { preset in
                        Button {
                            viewModel.annualRateText = preset.rate
                            viewModel.calculate()
                            activeField = .secondary
                        } label: {
                            Text(preset.label)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(
                                    viewModel.annualRateText == preset.rate
                                        ? Color.primary : Color.secondary
                                )
                                .padding(.horizontal, 10)
                                .frame(height: 28)
                                .background(Capsule().fill(
                                    viewModel.annualRateText == preset.rate
                                        ? Color.primary.opacity(0.10)
                                        : Color(uiColor: .systemGray5)
                                ))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                CursorTextField(
                    text: viewModel.annualRateText,
                    placeholder: "0",
                    uiFont: .systemFont(ofSize: 30, weight: .semibold).rounded,
                    isFocused: activeField == .secondary && !contentIsHero,
                    onTap: { activeField = .secondary }
                )
                .frame(width: 80, height: 38)

                Text("%")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary.opacity(0.40))
            }
        }
    }

    // MARK: - Slide Actions

    private func slideToHero() {
        withAnimation(.spring(response: 0.40, dampingFraction: 0.84)) {
            contentIsHero = true
            viewModel.isShowingHero = true
        }
    }

    private func slideToInput() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
            contentIsHero = false
            viewModel.isShowingHero = false
            heroDragX = 0
            activeField = .primary
        }
    }

    // MARK: - Helpers

    private var heroLabel: String {
        switch viewModel.method {
        case .equalInstallment: return "每月固定还款"
        case .equalPrincipal:   return "首月还款"
        case .interestFirst:    return "每月固定还息"
        }
    }
}

// MARK: - CursorTextField
// Wraps UITextField: shows native cursor, suppresses system keyboard.
// onTap fires on field tap so parent can route keyboard input correctly.

private struct CursorTextField: UIViewRepresentable {
    let text: String
    let placeholder: String
    let uiFont: UIFont
    let isFocused: Bool
    var alignment: NSTextAlignment = .right
    var onTap: () -> Void = {}

    func makeCoordinator() -> Coordinator { Coordinator(onTap: onTap) }

    class Coordinator: NSObject, UITextFieldDelegate {
        var onTap: () -> Void
        init(onTap: @escaping () -> Void) { self.onTap = onTap }

        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async { self.onTap() }
            return true
        }
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.delegate           = context.coordinator
        tf.inputView          = UIView()   // suppress system keyboard
        tf.inputAccessoryView = UIView()   // suppress toolbar
        tf.borderStyle        = .none
        tf.backgroundColor    = .clear
        tf.textAlignment      = alignment
        tf.adjustsFontSizeToFitWidth = true
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.smartDashesType    = .no
        tf.smartQuotesType    = .no
        tf.tintColor          = UIColor.label
        return tf
    }

    func updateUIView(_ tf: UITextField, context: Context) {
        context.coordinator.onTap = onTap
        tf.font = uiFont
        tf.textAlignment = alignment
        if tf.text != text { tf.text = text }
        if text.isEmpty && !isFocused {
            tf.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.label.withAlphaComponent(0.18)]
            )
        } else {
            tf.placeholder = nil
        }
        DispatchQueue.main.async {
            if isFocused && !tf.isFirstResponder {
                tf.becomeFirstResponder()
                let end = tf.endOfDocument
                tf.selectedTextRange = tf.textRange(from: end, to: end)
            } else if !isFocused && tf.isFirstResponder {
                tf.resignFirstResponder()
            }
        }
    }
}

// MARK: - UIFont convenience

private extension UIFont {
    var rounded: UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

// MARK: - Repayment Schedule Sheet

struct RepaymentScheduleSheet: View {
    let result: LoanResult
    let method: RepaymentMethod

    @Environment(\.dismiss) private var dismiss

    private var years: Int { Int(ceil(Double(result.schedule.count) / 12)) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    summaryRow("贷款本金",
                               value: ExpressionFormatter.formatCurrency(result.principal))
                    summaryRow("还款总额",
                               value: ExpressionFormatter.formatCurrency(result.totalRepayment))
                    summaryRow("利息总额",
                               value: ExpressionFormatter.formatCurrency(result.totalInterest),
                               valueColor: NumoColors.danger)
                    summaryRow("还款方式",
                               value: methodName)
                } header: { Text("贷款概览") }

                ForEach(1...max(years, 1), id: \.self) { year in
                    let entries = entriesForYear(year)
                    if !entries.isEmpty {
                        Section {
                            ForEach(entries) { entry in scheduleRow(entry) }
                        } header: { Text("第 \(year) 年") }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("还款明细")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }

    private var methodName: String {
        switch method {
        case .equalInstallment: return "等额本息"
        case .equalPrincipal:   return "等额本金"
        case .interestFirst:    return "先息后本"
        }
    }

    private func summaryRow(_ label: String, value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundStyle(valueColor)
        }
    }

    private func scheduleRow(_ entry: AmortizationEntry) -> some View {
        HStack(spacing: 0) {
            Text("第 \(entry.month) 期")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.secondary)
                .frame(width: 56, alignment: .leading)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(ExpressionFormatter.formatCurrency(entry.payment))
                    .font(.system(size: 13, weight: .medium, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.primary)
                HStack(spacing: 8) {
                    Text("本 \(ExpressionFormatter.formatCurrency(entry.principal))")
                        .foregroundStyle(Color.secondary)
                    Text("息 \(ExpressionFormatter.formatCurrency(entry.interest))")
                        .foregroundStyle(NumoColors.danger.opacity(0.80))
                }
                .font(.system(size: 10, design: .monospaced))
            }
        }
        .padding(.vertical, 2)
    }

    private func entriesForYear(_ year: Int) -> [AmortizationEntry] {
        let start = (year - 1) * 12
        let end   = min(year * 12, result.schedule.count)
        guard start < end else { return [] }
        return Array(result.schedule[start..<end])
    }
}

// MARK: - Preview

#Preview("贷款计算器") {
    let vm = LoanCalculatorViewModel()
    NavigationStack {
        LoanCalculatorView(viewModel: vm, activeField: .constant(.primary))
            .padding(.horizontal, NumoSpacing.md)
    }
    .onAppear {
        vm.amountText     = "100"
        vm.annualRateText = "3.45"
        vm.termMonths     = 360
        vm.calculate()
    }
}
