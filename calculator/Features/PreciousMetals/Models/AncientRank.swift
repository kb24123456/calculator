//
//  AncientRank.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/9.
//

import Foundation

struct AncientRank {
    let title: String
    let grade: String
    let dynasty: String
    let description: String
    let minSalary: Decimal
    let maxSalary: Decimal?

    static let all: [AncientRank] = [
        AncientRank(
            title: "衙役",
            grade: "无品",
            dynasty: "清代",
            description: "官府最基层差役，负责缉捕、站堂、押送",
            minSalary: 0,
            maxSalary: 1000
        ),
        AncientRank(
            title: "秀才",
            grade: "无品",
            dynasty: "清代",
            description: "通过县试的读书人，享有免徭役等特权",
            minSalary: 1000,
            maxSalary: 3000
        ),
        AncientRank(
            title: "县令",
            grade: "正七品",
            dynasty: "清代",
            description: "主管一县行政、司法，俗称「七品芝麻官」",
            minSalary: 3000,
            maxSalary: 6000
        ),
        AncientRank(
            title: "知州",
            grade: "正五品",
            dynasty: "清代",
            description: "管辖一州军政民事，地位高于县令",
            minSalary: 6000,
            maxSalary: 15000
        ),
        AncientRank(
            title: "知府",
            grade: "从四品",
            dynasty: "清代",
            description: "统辖一府数县，掌管钱粮、刑名、教化",
            minSalary: 15000,
            maxSalary: 30000
        ),
        AncientRank(
            title: "按察使",
            grade: "正三品",
            dynasty: "清代",
            description: "一省司法长官，掌管刑狱、监察百官",
            minSalary: 30000,
            maxSalary: 60000
        ),
        AncientRank(
            title: "巡抚",
            grade: "从二品",
            dynasty: "清代",
            description: "统管一省军政、民政，封疆大吏",
            minSalary: 60000,
            maxSalary: 100000
        ),
        AncientRank(
            title: "总督",
            grade: "正二品",
            dynasty: "清代",
            description: "辖两三省军政大权，位极人臣",
            minSalary: 100000,
            maxSalary: 200000
        ),
        AncientRank(
            title: "宰相",
            grade: "正一品",
            dynasty: "清代",
            description: "一人之下万人之上，总揽朝政",
            minSalary: 200000,
            maxSalary: nil
        ),
    ]

    static func find(monthlySalary: Decimal) -> AncientRank? {
        guard monthlySalary > 0 else { return nil }
        return all.last { monthlySalary >= $0.minSalary }
    }
}
