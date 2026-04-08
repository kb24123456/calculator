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
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CalculationRecord.timestamp, order: .reverse)
    private var records: [CalculationRecord]

    @State private var showClearConfirmation = false

    /// All tools except calculator — these are the ones users can toggle on/off
    private var toggleableTools: [Tool] {
        Tool.allCases.filter { $0 != .calculator }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: - Header
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(NumoColors.textSecondary)
                                .frame(width: 32, height: 32)
                        }
                        Spacer()
                        Text(String(localized: "设置"))
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Spacer()
                        // Invisible spacer to center title
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                    .padding(.horizontal, 20)

                    // MARK: - Quick Tools
                    settingsSection(title: String(localized: "快捷工具")) {
                        VStack(spacing: 0) {
                            ForEach(toggleableTools) { tool in
                                settingsRow {
                                    Image(systemName: tool.icon)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(tool.displayName)
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    Toggle("", isOn: Binding(
                                        get: { appState.isFavorite(tool) },
                                        set: { _ in
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                appState.toggleFavorite(tool)
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .tint(NumoColors.textSecondary)
                                }
                            }
                        }
                    }

                    // MARK: - Calculator
                    settingsSection(title: String(localized: "计算器")) {
                        VStack(spacing: 0) {
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "keyboard")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Text(String(localized: "运算符位置"))
                                    .font(.system(size: 16, design: .rounded))
                                Spacer()
                                Picker("", selection: $s.operatorOnRight) {
                                    Text(String(localized: "左侧")).tag(false)
                                    Text(String(localized: "右侧")).tag(true)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 120)
                            }
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "number")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Text(String(localized: "小数位数"))
                                    .font(.system(size: 16, design: .rounded))
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
                                .tint(NumoColors.textSecondary)
                            }
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "textformat.123")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Text(String(localized: "千分位"))
                                    .font(.system(size: 16, design: .rounded))
                                Spacer()
                                Picker("", selection: $s.thousandsSeparatorRaw) {
                                    ForEach(ThousandsSeparator.allCases) { sep in
                                        Text(sep.displayName).tag(sep.rawValue)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(NumoColors.textSecondary)
                            }
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Toggle(isOn: $s.autoCopyResult) {
                                    Text(String(localized: "自动复制结果"))
                                        .font(.system(size: 16, design: .rounded))
                                }
                                .tint(NumoColors.textSecondary)
                            }
                        }
                    }

                    // MARK: - Interaction
                    settingsSection(title: String(localized: "交互")) {
                        VStack(spacing: 0) {
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "hand.tap")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Toggle(isOn: $s.hapticEnabled) {
                                    Text(String(localized: "触感反馈"))
                                        .font(.system(size: 16, design: .rounded))
                                }
                                .tint(NumoColors.textSecondary)
                            }
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "speaker.wave.2")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Toggle(isOn: $s.soundEnabled) {
                                    Text(String(localized: "按键音效"))
                                        .font(.system(size: 16, design: .rounded))
                                }
                                .tint(NumoColors.textSecondary)
                            }
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Toggle(isOn: $s.clipboardDetection) {
                                    Text(String(localized: "剪贴板识别"))
                                        .font(.system(size: 16, design: .rounded))
                                }
                                .tint(NumoColors.textSecondary)
                            }
                        }
                    }

                    // MARK: - Appearance
                    settingsSection(title: String(localized: "外观")) {
                        VStack(spacing: 0) {
                            settingsRow {
                                @Bindable var s = settings
                                Image(systemName: "circle.lefthalf.filled")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(NumoColors.textSecondary)
                                    .frame(width: 24)
                                Text(String(localized: "外观模式"))
                                    .font(.system(size: 16, design: .rounded))
                                Spacer()
                                Picker("", selection: $s.themeRaw) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.displayName).tag(theme.rawValue)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 180)
                            }
                        }
                    }

                    // MARK: - Data
                    settingsSection(title: String(localized: "数据")) {
                        VStack(spacing: 0) {
                            if !records.isEmpty {
                                ShareLink(
                                    item: exportCSV(),
                                    preview: SharePreview(
                                        "Numo " + String(localized: "计算历史"),
                                        image: Image(systemName: "tablecells")
                                    )
                                ) {
                                    settingsRowContent {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(NumoColors.textSecondary)
                                            .frame(width: 24)
                                        Text(String(localized: "导出计算历史"))
                                            .font(.system(size: 16, design: .rounded))
                                        Spacer()
                                        chevron
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            Button {
                                showClearConfirmation = true
                            } label: {
                                settingsRowContent {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(records.isEmpty ? NumoColors.textTertiary : .red.opacity(0.8))
                                        .frame(width: 24)
                                    Text(String(localized: "清除计算历史"))
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundStyle(records.isEmpty ? NumoColors.textTertiary : NumoColors.textPrimary)
                                    Spacer()
                                    Text(String(localized: "\(records.count) 条"))
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(NumoColors.textTertiary)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(records.isEmpty)
                        }
                    }

                    // MARK: - About
                    settingsSection(title: String(localized: "关于")) {
                        VStack(spacing: 0) {
                            // Rate
                            Button { requestReview() } label: {
                                settingsRowContent {
                                    Image(systemName: "star")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "去 App Store 评分"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    chevron
                                }
                            }
                            .buttonStyle(.plain)

                            // Share
                            ShareLink(
                                item: URL(string: "https://apps.apple.com/app/numo")!,
                                preview: SharePreview(
                                    "Numo",
                                    image: Image(systemName: "plus.forwardslash.minus")
                                )
                            ) {
                                settingsRowContent {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "分享给朋友"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    chevron
                                }
                            }
                            .buttonStyle(.plain)

                            // Feedback
                            Link(destination: URL(string: "mailto:feedback@numo.app?subject=Numo%20%E5%8F%8D%E9%A6%88")!) {
                                settingsRowContent {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "意见反馈"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    externalChevron
                                }
                            }
                            .buttonStyle(.plain)

                            // Privacy
                            Link(destination: URL(string: "https://numo.app/privacy")!) {
                                settingsRowContent {
                                    Image(systemName: "hand.raised")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "隐私政策"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    externalChevron
                                }
                            }
                            .buttonStyle(.plain)

                            // Terms
                            Link(destination: URL(string: "https://numo.app/terms")!) {
                                settingsRowContent {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "使用条款"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    externalChevron
                                }
                            }
                            .buttonStyle(.plain)

                            // Acknowledgements
                            NavigationLink {
                                AcknowledgementsView()
                            } label: {
                                settingsRowContent {
                                    Image(systemName: "heart")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(NumoColors.textSecondary)
                                        .frame(width: 24)
                                    Text(String(localized: "致谢"))
                                        .font(.system(size: 16, design: .rounded))
                                    Spacer()
                                    chevron
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // MARK: - Footer
                    VStack(spacing: 4) {
                        Text("Numo")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(NumoColors.textTertiary)
                        Text("v\(appVersion)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(NumoColors.textTertiary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)
                }
                .padding(.top, 8)
            }
            .background(NumoColors.surface)
            .toolbar(.hidden, for: .navigationBar)
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

    // MARK: - Design Components

    /// Section with title header
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(NumoColors.textTertiary)
                .padding(.horizontal, 20)

            content()
        }
    }

    /// Standard row wrapper
    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    /// Row content without padding (for wrapping in Button/Link)
    private func settingsRowContent<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    /// Internal navigation chevron
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(NumoColors.textTertiary)
    }

    /// External link chevron
    private var externalChevron: some View {
        Image(systemName: "arrow.up.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(NumoColors.textTertiary)
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
