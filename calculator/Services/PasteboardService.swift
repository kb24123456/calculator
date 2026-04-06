//
//  PasteboardService.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import UIKit

struct PasteboardService {
    static func copy(_ text: String) {
        UIPasteboard.general.string = text
    }

    static func read() -> String? {
        UIPasteboard.general.string
    }
}
