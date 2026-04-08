//
//  SettingsView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(SettingsStore.self) private var settings
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CalculationRecord.timestamp, order: .reverse)
    private var records: [CalculationRecord]

    @State private var showClearConfirmation = false
    @State private var showExportSheet = false

    var body: some View {
        NavigationStack {
            Form {
                favoritesSection
                calculatorSection
                interactionSection
                displaySection
                dataSection
                aboutSection
            }
            .navigationTitle(String(localized: "设置"))
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                String(localized: "确认清除所有计算历史？"),
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button(String(localized: "清除"), role: .destructive) {
                    clearHistory()
                }
            } message: {
                Text(String(localized: "此操作不可撤销"))
            }
        }
    }

    // MARK: - Section 1: Quick Tools

    private var favoritesSection: some View {
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
        .environment(\.editMode, .constant(.active))
    }

    // MARK: - Section 2: Calculator

    private var calculatorSection: some View {
        @Bindable var s = settings
        return Section {
            // Keyboard layout
            HStack {
                Label(String(localized: "运算符位置"), systemImage: "keyboard")
                Spacer()
                Picker("", selection: $s.operatorOnRight) {
                    Text(String(localized: "左侧")).tag(false)
                    Text(String(localized: "右侧")).tag(true)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            // Decimal precision
            HStack {
                Label(String(localized: "小数位数"), systemImage: "number")
                Spacer()
                Picker("", selection: $s.decimalPrecision) {
                    Text(String(localized: "自动")).tag(-1)
                    Text("2").tag(2)
                    Text("4").tag(4)
                    Text("6").tag(6)
                    Text("8").tag(8)
                    Text("10").tag(10)
                }
                .pickerStyle(.menu)
            }

            // Thousands separator
            HStack {
                Label(String(localized: "千分位"), systemImage: "textformat.123")
                Spacer()
                Picker("", selection: $s.thousandsSeparatorRaw) {
                    ForEach(ThousandsSeparator.allCases) { sep in
                        Text(sep.displayName).tag(sep.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }

            // Auto copy
            Toggle(isOn: $s.autoCopyResult) {
                Label(String(localized: "自动复制结果"), systemImage: "doc.on.doc")
            }
        } header: {
            Text(String(localized: "计算器"))
        }
    }

    // MARK: - Section 3: Interaction

    private var interactionSection: some View {
        @Bindable var s = settings
        return Section {
            Toggle(isOn: $s.hapticEnabled) {
                Label(String(localized: "触感反馈"), systemImage: "hand.tap")
            }

            Toggle(isOn: $s.soundEnabled) {
                Label(String(localized: "按键音效"), systemImage: "speaker.wave.2")
            }

            Toggle(isOn: $s.clipboardDetection) {
                Label(String(localized: "剪贴板识别"), systemImage: "doc.on.clipboard")
            }
        } header: {
            Text(String(localized: "交互"))
        } footer: {
            Text(String(localized: "打开应用时自动识别剪贴板中的数字"))
        }
    }

    // MARK: - Section 4: Display

    private var displaySection: some View {
        @Bindable var s = settings
        return Section {
            HStack {
                Label(String(localized: "外观模式"), systemImage: "circle.lefthalf.filled")
                Spacer()
                Picker("", selection: $s.themeRaw) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme.rawValue)
                    }
                }
                .pickerStyle(.menu)
            }
        } header: {
            Text(String(localized: "显示"))
        }
    }

    // MARK: - Section 5: Data

    private var dataSection: some View {
        Section {
            // Export
            if !records.isEmpty {
                ShareLink(
                    item: exportCSV(),
                    preview: SharePreview(
                        "Numo " + String(localized: "计算历史"),
                        image: Image(systemName: "tablecells")
                    )
                ) {
                    Label(String(localized: "导出计算历史"), systemImage: "square.and.arrow.up")
                }
            }

            // Clear
            Button(role: .destructive) {
                showClearConfirmation = true
            } label: {
                Label(String(localized: "清除计算历史"), systemImage: "trash")
            }
            .disabled(records.isEmpty)
        } header: {
            Text(String(localized: "数据"))
        } footer: {
            Text(String(localized: "共 \(records.count) 条记录"))
        }
    }

    // MARK: - Section 6: About

    private var aboutSection: some View {
        Section {
            // Version
            HStack {
                Label(String(localized: "版本"), systemImage: "info.circle")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(NumoColors.textTertiary)
            }

            // Rate
            Button {
                requestReview()
            } label: {
                Label(String(localized: "去 App Store 评分"), systemImage: "star")
            }

            // Share
            ShareLink(
                item: URL(string: "https://apps.apple.com/app/numo")!,
                preview: SharePreview(
                    "Numo - " + String(localized: "万能计算器"),
                    image: Image(systemName: "plus.forwardslash.minus")
                )
            ) {
                Label(String(localized: "分享给朋友"), systemImage: "square.and.arrow.up")
            }

            // Feedback
            Link(destination: URL(string: "mailto:feedback@numo.app?subject=Numo%20%E5%8F%8D%E9%A6%88")!) {
                HStack {
                    Label(String(localized: "意见反馈"), systemImage: "envelope")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(NumoColors.textTertiary)
                }
            }

            // Privacy policy
            Link(destination: URL(string: "https://numo.app/privacy")!) {
                HStack {
                    Label(String(localized: "隐私政策"), systemImage: "hand.raised")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(NumoColors.textTertiary)
                }
            }

            // Terms
            Link(destination: URL(string: "https://numo.app/terms")!) {
                HStack {
                    Label(String(localized: "使用条款"), systemImage: "doc.text")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundStyle(NumoColors.textTertiary)
                }
            }

            // Acknowledgements
            NavigationLink {
                AcknowledgementsView()
            } label: {
                Label(String(localized: "致谢"), systemImage: "heart")
            }
        } header: {
            Text(String(localized: "关于"))
        } footer: {
            Text("Numo · Made with ♡")
                .frame(maxWidth: .infinity)
                .padding(.top, NumoSpacing.md)
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        SKStoreReviewController.requestReview(in: scene)
    }

    private func clearHistory() {
        for record in records {
            modelContext.delete(record)
        }
        try? modelContext.save()
    }

    private func exportCSV() -> String {
        var csv = "Expression,Result,Timestamp\n"
        let formatter = ISO8601DateFormatter()
        for record in records {
            let expr = record.expression.replacingOccurrences(of: ",", with: " ")
            let result = record.result.replacingOccurrences(of: ",", with: " ")
            let date = formatter.string(from: record.timestamp)
            csv += "\(expr),\(result),\(date)\n"
        }
        return csv
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
        .environment(SettingsStore())
}
