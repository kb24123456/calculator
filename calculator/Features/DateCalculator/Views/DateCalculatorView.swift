//
//  DateCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct DateCalculatorView: View {
    @State private var viewModel = DateCalculatorViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: NumoSpacing.lg) {
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

                Spacer()
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.top, NumoSpacing.md)
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
                        if result.weeks > 0 {
                            Text(String(localized: "\(result.weeks) 周 \(result.remainingDays) 天"))
                                .font(NumoTypography.bodyMedium)
                                .foregroundStyle(NumoColors.textSecondary)
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

            HStack(spacing: NumoSpacing.xs) {
                NumoTextField(title: String(localized: "天数"), text: $viewModel.offsetDays, keyboardType: .numberPad)
                    .onChange(of: viewModel.offsetDays) { viewModel.calculateOffset() }

                NumoSegmentedControl(
                    options: [(String(localized: "之后"), true), (String(localized: "之前"), false)],
                    selection: $viewModel.offsetForward
                )
                .frame(width: 140)
                .onChange(of: viewModel.offsetForward) { viewModel.calculateOffset() }
            }

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

            HStack(spacing: NumoSpacing.xs) {
                NumoTextField(title: String(localized: "工作日天数"), text: $viewModel.workdayCount, keyboardType: .numberPad)
                    .onChange(of: viewModel.workdayCount) { viewModel.calculateWorkday() }

                NumoSegmentedControl(
                    options: [(String(localized: "之后"), true), (String(localized: "之前"), false)],
                    selection: $viewModel.workdayForward
                )
                .frame(width: 140)
                .onChange(of: viewModel.workdayForward) { viewModel.calculateWorkday() }
            }

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

#Preview {
    DateCalculatorView()
}
