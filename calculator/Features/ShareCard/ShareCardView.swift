//
//  ShareCardView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

/// Data model for a share card
struct ShareCardData {
    let toolName: String
    let toolIcon: String
    let headline: String          // Primary result
    let subtitle: String?         // Secondary info (rate, unit, etc.)
    let detail: String?           // Tertiary info
}

/// Renders a branded share card for any tool result.
/// Used with `ImageRenderer` to produce a shareable image.
struct ShareCardView: View {
    let data: ShareCardData
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 32)

            // Tool badge
            HStack(spacing: 6) {
                Image(systemName: data.toolIcon)
                    .font(.system(size: 13, weight: .medium))
                Text(data.toolName)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )

            Spacer(minLength: 24)

            // Headline result
            Text(data.headline)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 24)

            // Subtitle
            if let subtitle = data.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
            }

            // Detail
            if let detail = data.detail, !detail.isEmpty {
                Text(detail)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .padding(.horizontal, 24)
            }

            Spacer(minLength: 32)

            // Branding footer
            HStack(spacing: 6) {
                Text("Numo")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.tertiary)
                Circle()
                    .fill(.tertiary)
                    .frame(width: 3, height: 3)
                Text(formattedDate)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundStyle(.quaternary)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 360, height: 400)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
        )
        .padding(20)
    }

    private var formattedDate: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy.MM.dd HH:mm"
        return fmt.string(from: Date())
    }
}

// MARK: - Image Rendering

extension ShareCardView {
    /// Renders the card as a UIImage for sharing.
    @MainActor
    func renderImage() -> UIImage? {
        let renderer = ImageRenderer(content: self.environment(\.colorScheme, .light))
        renderer.scale = 3.0  // @3x for crisp sharing
        return renderer.uiImage
    }
}

#Preview {
    ShareCardView(data: ShareCardData(
        toolName: "汇率",
        toolIcon: "coloncurrencysign.arrow.trianglehead.counterclockwise.rotate.90",
        headline: "¥ 7,251.30",
        subtitle: "1,000 USD → CNY",
        detail: "1 USD = 7.2513 CNY"
    ))
}
