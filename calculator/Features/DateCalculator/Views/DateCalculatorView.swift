//
//  DateCalculatorView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

// MARK: - Main View

struct DateCalculatorView: View {
    @Bindable var viewModel: DateCalculatorViewModel
    @State private var showStartPicker = false
    @State private var showEndPicker   = false

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月d日 EEE"
        return f
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                switch viewModel.mode {
                case .difference: differenceLayout
                case .offset:     offsetLayout
                case .workday:    workdayLayout
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 80)
        }
        .onChange(of: viewModel.mode) { _, _ in
            showStartPicker = false
            showEndPicker   = false
        }
        .sheet(isPresented: $showStartPicker) {
            switch viewModel.mode {
            case .difference:
                DatePickerSheet(date: $viewModel.startDate, title: "开始日期") {
                    viewModel.calculateDifference()
                }
            case .offset:
                DatePickerSheet(date: $viewModel.offsetStartDate, title: "起始日期") {
                    viewModel.calculateOffset()
                }
            case .workday:
                DatePickerSheet(date: $viewModel.workdayStartDate, title: "起始日期") {
                    viewModel.calculateWorkday()
                }
            }
        }
        .sheet(isPresented: $showEndPicker) {
            DatePickerSheet(date: $viewModel.endDate, title: "结束日期") {
                viewModel.calculateDifference()
            }
        }
    }

    // MARK: - Difference Layout

    private var differenceLayout: some View {
        VStack(spacing: 16) {
            differenceCard
            differenceHero
        }
    }

    private var differenceCard: some View {
        HStack(alignment: .center, spacing: 14) {
            // ── Timeline rail ──
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
            }
            .opacity(0.25)
            .frame(width: 8)
            .padding(.vertical, 18)

            // ── Date blocks ──
            VStack(spacing: 0) {
                dateBlock(
                    label: "开始日期",
                    date: viewModel.startDate,
                    action: { showStartPicker = true }
                )
                Divider().padding(.horizontal, 4).opacity(0.5)
                dateBlock(
                    label: "结束日期",
                    date: viewModel.endDate,
                    action: { showEndPicker = true }
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    private var differenceHero: some View {
        let days: Int
        let supplement: String

        if let result = viewModel.differenceResult {
            let d = abs(result.days)
            days = d
            let months = d / 30
            let rem    = d % 30
            let wdays  = Int(Double(d) * 5.0 / 7.0)
            if months > 0 {
                supplement = "折合 \(months) 个月零 \(rem) 天 · 约 \(wdays) 个工作日"
            } else {
                supplement = "约 \(wdays) 个工作日"
            }
        } else {
            days = 0
            supplement = "选择开始和结束日期"
        }

        return VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Spacer()
                Text("\(days)")
                    .font(.system(size: 72, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(days == 0 ? Color.primary.opacity(0.18) : Color.primary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.38, dampingFraction: 0.75), value: days)
                Text("天")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.primary.opacity(days == 0 ? 0.12 : 0.60))
                    .padding(.bottom, 6)
            }
            Text(supplement)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(Color.secondary.opacity(0.60))
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    // MARK: - Offset Layout

    private var offsetLayout: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                dateBlock(
                    label: "起始日期",
                    date: viewModel.offsetStartDate,
                    action: { showStartPicker = true }
                )
                Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)
                stepperRow(
                    label: "推算天数",
                    value: viewModel.offsetDays,
                    onDecrement: {
                        let v = max(1, (Int(viewModel.offsetDays) ?? 1) - 1)
                        viewModel.offsetDays = "\(v)"
                        viewModel.calculateOffset()
                    },
                    onIncrement: {
                        let v = (Int(viewModel.offsetDays) ?? 0) + 1
                        viewModel.offsetDays = "\(v)"
                        viewModel.calculateOffset()
                    }
                )
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 12)
                Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)
                directionRow(forward: $viewModel.offsetForward) {
                    viewModel.calculateOffset()
                }
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )

            offsetHero
        }
    }

    private var offsetHero: some View {
        heroDateBlock(
            date: viewModel.offsetResult,
            placeholder: "选择起始日期并输入天数"
        )
    }

    // MARK: - Workday Layout

    private var workdayLayout: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                dateBlock(
                    label: "起始日期",
                    date: viewModel.workdayStartDate,
                    action: { showStartPicker = true }
                )
                Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)
                stepperRow(
                    label: "工作日天数",
                    value: viewModel.workdayCount,
                    onDecrement: {
                        let v = max(1, (Int(viewModel.workdayCount) ?? 1) - 1)
                        viewModel.workdayCount = "\(v)"
                        viewModel.calculateWorkday()
                    },
                    onIncrement: {
                        let v = (Int(viewModel.workdayCount) ?? 0) + 1
                        viewModel.workdayCount = "\(v)"
                        viewModel.calculateWorkday()
                    }
                )
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 12)
                Divider().padding(.horizontal, NumoSpacing.md).opacity(0.5)
                directionRow(forward: $viewModel.workdayForward) {
                    viewModel.calculateWorkday()
                }
                .padding(.horizontal, NumoSpacing.md)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )

            workdayHero
        }
    }

    private var workdayHero: some View {
        let supplement: String? = viewModel.workdayResult != nil
            ? "经过 \(viewModel.workdayCalendarDays) 个自然日，跳过 \(viewModel.workdaySkippedDays) 天"
            : nil
        return heroDateBlock(
            date: viewModel.workdayResult,
            supplement: supplement,
            placeholder: "选择起始日期并输入天数"
        )
    }

    // MARK: - Shared Components

    private func dateBlock(label: String, date: Date, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.55))
                    Text(Self.dateFmt.string(from: date))
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.primary)
                }
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondary.opacity(0.30))
            }
            .padding(.horizontal, NumoSpacing.md)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func stepperRow(
        label: String,
        value: String,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary.opacity(0.55))
            Spacer()
            HStack(spacing: 14) {
                // Decrement
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color(uiColor: .systemGray5)))
                }
                .buttonStyle(.plain)
                .disabled((Int(value) ?? 0) <= 1)

                // Value
                Text(value.isEmpty ? "0" : value)
                    .font(.system(size: 26, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(Color.primary)
                    .frame(minWidth: 44, alignment: .center)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: value)

                // Increment
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(Color(uiColor: .systemGray5)))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func directionRow(forward: Binding<Bool>, onChange: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Text("方向")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.secondary.opacity(0.55))
            Spacer()
            HStack(spacing: 8) {
                directionButton(title: "之后", isSelected: forward.wrappedValue) {
                    forward.wrappedValue = true
                    onChange()
                }
                directionButton(title: "之前", isSelected: !forward.wrappedValue) {
                    forward.wrappedValue = false
                    onChange()
                }
            }
        }
    }

    private func directionButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.horizontal, 18)
                .frame(height: 32)
                .background(
                    Capsule().fill(
                        isSelected
                            ? Color.primary.opacity(0.10)
                            : Color(uiColor: .systemGray5)
                    )
                )
        }
        .buttonStyle(.plain)
    }

    private func heroDateBlock(
        date: Date?,
        supplement: String? = nil,
        placeholder: String
    ) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                if let date {
                    Text(Self.dateFmt.string(from: date))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.38, dampingFraction: 0.75), value: date.timeIntervalSince1970)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.35))
                }
            }
            if let supplement, date != nil {
                Text(supplement)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Color.secondary.opacity(0.60))
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - DatePickerSheet

private struct DatePickerSheet: View {
    @Binding var date: Date
    let title: String
    let onChange: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.primary)
                Spacer()
                Button("完成") { dismiss() }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(NumoColors.danger)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 4)

            // ── Picker ──
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(NumoColors.danger)
                .padding(.horizontal, 8)
                .onChange(of: date) { _, _ in onChange() }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
