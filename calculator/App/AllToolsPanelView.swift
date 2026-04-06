//
//  AllToolsPanelView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI

struct AllToolsPanelView: View {
    @Environment(AppState.self) private var appState

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: NumoSpacing.md) {
                    ForEach(Tool.allCases.filter { $0 != .calculator }) { tool in
                        AllToolCard(
                            tool: tool,
                            isSelected: appState.selectedTool == tool,
                            isFavorite: appState.isFavorite(tool),
                            canAddFavorite: true,
                            onSelect: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                                appState.selectTool(tool)
                            },
                            onToggleFavorite: {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
                                withAnimation(NumoAnimations.interactiveSpring) {
                                    appState.toggleFavorite(tool)
                                }
                            }
                        )
                    }
                }
                .padding(NumoSpacing.md)

                // Favorites count indicator
            }
            .navigationTitle(String(localized: "全部工具"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Tool Card

private struct AllToolCard: View {
    let tool: Tool
    let isSelected: Bool
    let isFavorite: Bool
    let canAddFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: NumoSpacing.xs) {
                ZStack(alignment: .topTrailing) {
                    // Tool icon centered
                    Image(systemName: tool.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(
                            isSelected
                                ? NumoColors.chipSelected
                                : NumoColors.textSecondary
                        )
                        .frame(maxWidth: .infinity)

                    // Favorite toggle
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundStyle(isFavorite ? Color.orange : NumoColors.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isFavorite && !canAddFavorite)
                    .opacity(!isFavorite && !canAddFavorite ? 0.3 : 1.0)
                }

                Text(tool.displayName)
                    .font(NumoTypography.bodyMedium)
                    .foregroundStyle(NumoColors.textPrimary)
            }
            .padding(.vertical, NumoSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NumoColors.surfaceSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? NumoColors.chipSelected : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(NumoAnimations.chipSelection, value: isFavorite)
    }
}

#Preview {
    AllToolsPanelView()
        .environment(AppState())
}
