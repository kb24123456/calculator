//
//  ContentView.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//
//  This file is kept for Xcode compatibility but is no longer used.
//  The app entry point now uses NumoTabView directly.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NumoTabView()
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(HapticService())
}
