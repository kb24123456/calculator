//
//  OnboardingView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "rectangle.grid.1x2",
            title: "万能计算器",
            description: "不只是计算器——汇率、贷款、单位换算、日期推算，所有工具共享一个键盘，一键切换。",
            highlight: "顶部胶囊切换工具"
        ),
        OnboardingPage(
            icon: "star",
            title: "自定义常用工具",
            description: "点击 + 号发现全部工具，长按星标收藏。你的高频工具，永远触手可及。",
            highlight: "收藏你最常用的"
        ),
        OnboardingPage(
            icon: "hand.tap",
            title: "长按复制，分享结果",
            description: "长按结果区域一键复制。点击右上角分享按钮，生成精美卡片发送给同事。",
            highlight: "试试看"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 360)

            Spacer(minLength: 24)

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? NumoColors.accentRed : NumoColors.textTertiary.opacity(0.3))
                        .frame(width: index == currentPage ? 20 : 6, height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }
            .padding(.bottom, 32)

            // CTA Button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    dismiss()
                }
            } label: {
                Text(currentPage < pages.count - 1
                     ? String(localized: "继续")
                     : String(localized: "开始使用"))
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(NumoColors.accentRed)
                    )
            }
            .padding(.horizontal, 24)
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: currentPage)

            // Skip button
            if currentPage < pages.count - 1 {
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "跳过"))
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(NumoColors.textTertiary)
                }
                .padding(.top, 12)
                .transition(.opacity)
            }

            Spacer(minLength: 20)
        }
        .background(NumoColors.surface)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(NumoColors.accentRed)
                .frame(height: 72)

            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(NumoColors.textPrimary)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(NumoColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            // Highlight chip
            Text(page.highlight)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(NumoColors.accentRed)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(NumoColors.accentRed.opacity(0.1))
                )
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

// MARK: - Page Model

private struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let highlight: String
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
