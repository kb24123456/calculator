//
//  NumoBundle.swift
//  Numo
//
//  Created by 廖云丰 on 2026/4/9.
//

import WidgetKit
import SwiftUI

@main
struct NumoWidgetBundle: WidgetBundle {
    var body: some Widget {
        GoldPriceWidget()
        CurrencyPairWidget()
    }
}
