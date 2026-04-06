//
//  NumoTabView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct NumoTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Tool Toolbar
            toolToolbar
                .padding(.top, NumoSpacing.xs)

            // MARK: - Content Area
            toolContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(NumoColors.surface)
        .sheet(isPresented: Binding(
            get: { appState.isDrawerOpen },
            set: { appState.isDrawerOpen = $0 }
        )) {
            ToolDrawerView()
                .environment(appState)
                .presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Toolbar

    private var toolToolbar: some View {
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
            .padding(.horizontal, NumoSpacing.md)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var toolContent: some View {
        Group {
            switch appState.selectedTool {
            case .calculator:
                CalculatorView()
            case .currency:
                PlaceholderToolView(tool: .currency)
            case .uppercase:
                PlaceholderToolView(tool: .uppercase)
            case .yoy:
                PlaceholderToolView(tool: .yoy)
            case .incomeTax:
                PlaceholderToolView(tool: .incomeTax)
            case .date:
                PlaceholderToolView(tool: .date)
            case .unit:
                PlaceholderToolView(tool: .unit)
            case .loan:
                PlaceholderToolView(tool: .loan)
            }
        }
        .transition(.toolSwitch)
        .id(appState.selectedTool)
    }
}

// MARK: - Placeholder for unimplemented tools

struct PlaceholderToolView: View {
    let tool: Tool

    var body: some View {
        VStack(spacing: NumoSpacing.lg) {
            Image(systemName: tool.icon)
                .font(.system(size: 48))
                .foregroundStyle(NumoColors.textTertiary)
            Text(tool.displayName)
                .font(NumoTypography.titleMedium)
                .foregroundStyle(NumoColors.textSecondary)
            Text(String(localized: "即将推出"))
                .font(NumoTypography.bodySmall)
                .foregroundStyle(NumoColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            appState.selectTool(tool)
                        } label: {
                            VStack(spacing: NumoSpacing.xs) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(
                                        appState.selectedTool == tool
                                            ? NumoColors.accentRed
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

#Preview {
    NumoTabView()
        .environment(AppState())
        .environment(HapticService())
}
