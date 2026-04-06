//
//  LoanCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only loan dashboard view. Keypad input managed by NumoTabView.
struct LoanCalculatorView: View {
    let viewModel: LoanCalculatorViewModel
    @Binding var activeField: ToolInputField
    var onScrollCollapse: (() -> Void)?

    @Namespace private var strategyNS
    @State private var pressedTerm: Int? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                capitalCard
                strategyToggle
                if let result = viewModel.result {
                    heroResult(result)
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                }
            }
            .padding(.top, NumoSpacing.sm)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.result != nil)
            .animation(.spring(response: 0.35, dampingFraction: 0.78), value: viewModel.method)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 40)
                .onChanged { value in
                    if value.translation.height < -40 { onScrollCollapse?() }
                }
        )
    }

    // MARK: — Capital Card

    private var capitalCard: some View {
        VStack(spacing: 0) {

            // ── 金额 ──
            Button { activeField = .primary } label: {
                VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                    Text("贷款金额")
                        .font(.caption)
                        .foregroundStyle(activeField == .primary ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tertiary))

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Spacer(minLength: 0)
                        Text(viewModel.amountText.isEmpty ? "0" : viewModel.amountText)
                            .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(viewModel.amountText.isEmpty ? Color.tertiary : Color.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.15), value: viewModel.amountText)
                        Text("万")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.tertiary)
                            .offset(y: -4)
                    }
                }
                .padding(.horizontal, NumoSpacing.md)
                .padding(.top, NumoSpacing.sm)
                .padding(.bottom, NumoSpacing.xs)
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.15), value: activeField == .primary)

            Divider().padding(.horizontal, NumoSpacing.md)

            // ── 期限 ──
            VStack(alignment: .leading, spacing: NumoSpacing.xs) {
                Text("贷款期限")
                    .font(.caption)
                    .foregroundStyle(Color.tertiary)
                    .padding(.horizontal, NumoSpacing.md)
                    .padding(.top, NumoSpacing.sm)

                HStack(spacing: NumoSpacing.xs) {
                    ForEach(LoanCalculatorViewModel.termPresets, id: \.months) { preset in
                        let isSelected = viewModel.termMonths == preset.months
                        Button {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.58)) {
                                pressedTerm = preset.months
                            }
                            viewModel.termMonths = preset.months
                            viewModel.calculate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                                pressedTerm = nil
                            }
                        } label: {
                            Text(preset.label)
                                .font(.system(size: 13,
                                              weight: isSelected ? .semibold : .regular,
                                              design: .rounded))
                                .foregroundStyle(isSelected ? NumoColors.chipSelectedText : NumoColors.chipDefaultText)
                                .padding(.horizontal, NumoSpacing.sm)
                                .frame(height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(isSelected ? NumoColors.chipSelected : NumoColors.chipDefault)
                                )
                                .scaleEffect(pressedTerm == preset.months ? 1.16 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.26, dampingFraction: 0.58), value: pressedTerm)
                        .animation(NumoAnimations.chipSelection, value: viewModel.termMonths)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, NumoSpacing.md)
                .padding(.bottom, NumoSpacing.sm)
            }

            Divider().padding(.horizontal, NumoSpacing.md)

            // ── 利率 ──
            Button { activeField = .secondary } label: {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                        Text("年利率")
                            .font(.caption)
                            .foregroundStyle(activeField == .secondary ? Color.secondary : Color.tertiary)

                        HStack(spacing: NumoSpacing.xxs) {
                            ForEach(LoanCalculatorViewModel.ratePresets, id: \.rate) { preset in
                                Button {
                                    viewModel.annualRateText = preset.rate
                                    viewModel.calculate()
                                } label: {
                                    Text(preset.label)
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(
                                            viewModel.annualRateText == preset.rate
                                                ? Color.primary : NumoColors.chipDefaultText
                                        )
                                        .padding(.horizontal, NumoSpacing.xs)
                                        .frame(height: 20)
                                        .background(Capsule().fill(NumoColors.chipDefault))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(viewModel.annualRateText.isEmpty ? "0" : viewModel.annualRateText)
                            .font(.system(size: 28, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(
                                viewModel.annualRateText.isEmpty ? Color.tertiary
                                    : (activeField == .secondary ? Color.primary : Color.secondary)
                            )
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.15), value: viewModel.annualRateText)
                        Text("%")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tertiary)
                    }
                }
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, NumoSpacing.sm)
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.15), value: activeField == .secondary)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NumoColors.surfaceSecondary)
        )
    }

    // MARK: — Strategy Toggle (matchedGeometryEffect 滑动背景)

    private var strategyToggle: some View {
        HStack(spacing: 0) {
            ForEach([RepaymentMethod.equalInstallment, .equalPrincipal], id: \.rawValue) { m in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                        viewModel.method = m
                        viewModel.calculate()
                    }
                } label: {
                    ZStack {
                        if viewModel.method == m {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primary)
                                .matchedGeometryEffect(id: "strategyBG", in: strategyNS)
                        }
                        Text(m == .equalInstallment ? "等额本息" : "等额本金")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                viewModel.method == m
                                    ? Color(uiColor: .systemBackground)
                                    : Color.secondary
                            )
                            .animation(nil, value: viewModel.method)  // 防止文字颜色被 spring 拉伸
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(NumoColors.surfaceSecondary)
        )
    }

    // MARK: — Hero Result

    private func heroResult(_ result: LoanResult) -> some View {
        VStack(spacing: 0) {

            // ── 月供 Hero ──
            VStack(spacing: NumoSpacing.xs) {
                Text(viewModel.method == .equalInstallment ? "每月固定还款" : "首月还款")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)

                Text(ExpressionFormatter.formatCurrency(result.monthlyPayment))
                    .font(.system(size: 64, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.monthlyPayment)

                if let last = result.lastMonthPayment {
                    Text("末月 \(ExpressionFormatter.formatCurrency(last))")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(Color.tertiary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: last)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, NumoSpacing.xl)
            .padding(.bottom, NumoSpacing.lg)

            Divider().padding(.horizontal, NumoSpacing.lg)

            // ── 成本分析 ──
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: NumoSpacing.xxs) {
                    Text("总还款")
                        .font(.caption2)
                        .foregroundStyle(Color.tertiary)
                    Text(ExpressionFormatter.formatCurrency(result.totalRepayment))
                        .font(.system(size: 18, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.totalRepayment)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: NumoSpacing.xxs) {
                    Text("总利息")
                        .font(.caption2)
                        .foregroundStyle(Color.tertiary)
                    Text(ExpressionFormatter.formatCurrency(result.totalInterest))
                        .font(.system(size: 18, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(NumoColors.danger)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: result.totalInterest)
                }
            }
            .padding(.horizontal, NumoSpacing.lg)
            .padding(.vertical, NumoSpacing.md)

            Divider().padding(.horizontal, NumoSpacing.lg)

            // ── 明细引导 ──
            Button { viewModel.showSchedule = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 11))
                    Text("查看还款明细")
                        .font(.system(size: 12, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundStyle(Color.tertiary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, NumoSpacing.sm)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(NumoColors.surfaceSecondary)
        )
    }
}
