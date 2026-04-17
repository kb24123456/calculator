//
//  calculatorTests.swift
//  calculatorTests
//
//  Created by 廖云丰 on 2026/4/6.
//

import Testing
@testable import calculator

struct calculatorTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }

}

struct ClipboardNumberParsingTests {

    @Test func 纯数字_直接返回() {
        #expect(NumoTabView.parseClipboardNumber("12345") == "12345")
    }

    @Test func 带千位分隔符_去除分隔符() {
        #expect(NumoTabView.parseClipboardNumber("1,234,567.89") == "1234567.89")
    }

    @Test func 带货币符号和空格_去除() {
        #expect(NumoTabView.parseClipboardNumber(" ¥ 99.5 ") == "99.5")
        #expect(NumoTabView.parseClipboardNumber("$1,000") == "1000")
    }

    @Test func 中文逗号_去除() {
        #expect(NumoTabView.parseClipboardNumber("1，234") == "1234")
    }

    @Test func 非法空字符串_返回nil() {
        #expect(NumoTabView.parseClipboardNumber("") == nil)
        #expect(NumoTabView.parseClipboardNumber("   ") == nil)
    }

    @Test func 非法非数字_返回nil() {
        #expect(NumoTabView.parseClipboardNumber("hello") == nil)
        #expect(NumoTabView.parseClipboardNumber("¥¥¥") == nil)
    }

    @Test func 超长_返回nil() {
        let long = String(repeating: "9", count: 16)
        #expect(NumoTabView.parseClipboardNumber(long) == nil)
    }

    @Test func 中文句号当小数点() {
        #expect(NumoTabView.parseClipboardNumber("99。5") == "99.5")
    }
}
