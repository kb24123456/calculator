//
//  AcknowledgementsView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import SwiftUI

struct AcknowledgementsView: View {
    private let dataSources: [(name: String, description: String, url: String)] = [
        ("Frankfurter", String(localized: "开源汇率 API"), "https://www.frankfurter.app"),
        ("Stooq", String(localized: "实时贵金属行情"), "https://stooq.com"),
        ("fawazahmed0/currency-api", String(localized: "汇率备用数据源"), "https://github.com/fawazahmed0/exchange-api"),
    ]

    var body: some View {
        List {
            Section {
                ForEach(dataSources, id: \.name) { source in
                    Link(destination: URL(string: source.url)!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(source.name)
                                    .font(NumoTypography.bodyMedium)
                                    .foregroundStyle(NumoColors.textPrimary)
                                Text(source.description)
                                    .font(NumoTypography.caption)
                                    .foregroundStyle(NumoColors.textTertiary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundStyle(NumoColors.textTertiary)
                        }
                    }
                }
            } header: {
                Text(String(localized: "数据来源"))
            } footer: {
                Text(String(localized: "以上服务为本应用提供汇率和贵金属价格数据，特此致谢。"))
            }
        }
        .navigationTitle(String(localized: "致谢"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
}
