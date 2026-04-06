//
//  DateCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

/// Display-only date calculator view.
/// For offset/workday modes, keypad input is managed by NumoTabView.
/// For difference mode, uses DatePickers only.
struct DateCalculatorView: View {
    @Bindable var viewModel: DateCalculatorViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: NumoSpacing.md) {
                NumoSegmentedControl(
                    options: [
                        (String(localized: "日期间隔"), DateCalcMode.difference),
                        (String(localized: "日期推算"), DateCalcMode.offset),
                        (String(localized: "工作日"), DateCalcMode.workday),
                    ],
                    selection: $viewModel.mode
                )

                switch viewModel.mode {
                case .difference:
                    differenceModeView
                case .offset:
                    offsetModeView
                case .workday:
                    workdayModeView
                }
            }
            .padding(.top, NumoSpacing.sm)
        }
    }

    // MARK: - Difference

    private var differenceModeView: some View {
        VStack(spacing: NumoSpacing.md) {
            datePicker(label: String(localized: "开始日期"), date: $viewModel.startDate)
                .onChange(of: viewModel.startDate) { viewModel.calculateDifference() }
            datePicker(label: String(localized: "结束日期"), date: $viewModel.endDate)
                .onChange(of: viewModel.endDate) { viewModel.calculateDifference() }

            if let result = viewModel.differenceResult {
                NumoCard {
                    VStack(spacing: NumoSpacing.xs) {
                        Text(String(localized: "相差 \(abs(result.days)) 天"))
                            .font(NumoTypography.titleLarge)
                            .foregroundStyle(NumoColors.textPrimary)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: result.days)
                        if result.weeks > 0 {
                            Text(String(localized: "\(result.weeks) 周 \(result.remainingDays) 天"))
                                .font(NumoTypography.bodyMedium)
                                .foregroundStyle(NumoColors.textSecondary)
                                .contentTransition(.numericText())
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear { viewModel.calculateDifference() }
    }

    // MARK: - Offset

    private var offsetModeView: some View {
        VStack(spacing: NumoSpacing.md) {
            datePicker(label: String(localized: "起始日期"), date: $viewModel.offsetStartDate)

            // Days input display (keypad feeds into this)
            HStack {
                Text(String(localized: "天数"))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                Spacer()
                Text(viewModel.offsetDays.isEmpty ? "0" : viewModel.offsetDays)
                    .font(NumoTypography.monoTitleLarge)
                    .foregroundStyle(NumoColors.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: viewModel.offsetDays)
            }
            .padding(.horizontal, NumoSpacing.md)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(NumoColors.accentRed.opacity(0.5), lineWidth: 1.5)
                    )
            )

            NumoSegmentedControl(
                options: [(String(localized: "之后"), true), (String(localized: "之前"), false)],
                selection: $viewModel.offsetForward
            )
            .onChange(of: viewModel.offsetForward) { viewModel.calculateOffset() }

            if let result = viewModel.offsetResult {
                NumoCard {
                    VStack(spacing: NumoSpacing.xs) {
                        Text(result, style: .date)
                            .font(NumoTypography.titleLarge)
                            .foregroundStyle(NumoColors.textPrimary)
                        Text(weekdayString(result))
                            .font(NumoTypography.bodyMedium)
                            .foregroundStyle(NumoColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Workday

    private var workdayModeView: some View {
        VStack(spacing: NumoSpacing.md) {
            datePicker(label: String(localized: "起始日期"), date: $viewModel.workdayStartDate)

            // Workday count display (keypad feeds into this)
            HStack {
                Text(String(localized: "工作日天数"))
                    .font(NumoTypography.bodySmall)
                    .foregroundStyle(NumoColors.textSecondary)
                Spacer()
                Text(viewModel.workdayCount.isEmpty ? "0" : viewModel.workdayCount)
                    .font(NumoTypography.monoTitleLarge)
                    .foregroundStyle(NumoColors.textPrimary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: viewModel.workdayCount)
            }
            .padding(.horizontal, NumoSpacing.md)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(NumoColors.accentRed.opacity(0.5), lineWidth: 1.5)
                    )
            )

            NumoSegmentedControl(
                options: [(String(localized: "之后"), true), (String(localized: "之前"), false)],
                selection: $viewModel.workdayForward
            )
            .onChange(of: viewModel.workdayForward) { viewModel.calculateWorkday() }

            Toggle(String(localized: "排除中国法定节假日"), isOn: $viewModel.includeHolidays)
                .font(NumoTypography.bodyMedium)
                .tint(NumoColors.accentRed)
                .onChange(of: viewModel.includeHolidays) { viewModel.calculateWorkday() }

            if let result = viewModel.workdayResult {
                NumoCard {
                    VStack(spacing: NumoSpacing.xs) {
                        Text(result, style: .date)
                            .font(NumoTypography.titleLarge)
                            .foregroundStyle(NumoColors.textPrimary)
                        Text(weekdayString(result))
                            .font(NumoTypography.bodyMedium)
                            .foregroundStyle(NumoColors.textSecondary)
                        Text(String(localized: "经过 \(viewModel.workdayCalendarDays) 个自然日，跳过 \(viewModel.workdaySkippedDays) 天"))
                            .font(NumoTypography.caption)
                            .foregroundStyle(NumoColors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Helpers

    private func datePicker(label: String, date: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(NumoTypography.bodyMedium)
                .foregroundStyle(NumoColors.textSecondary)
            Spacer()
            DatePicker("", selection: date, displayedComponents: .date)
                .labelsHidden()
        }
    }

    private func weekdayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}
