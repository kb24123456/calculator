//
//  calculatorApp.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import SwiftData

@main
struct calculatorApp: App {
    @State private var appState = AppState()
    @State private var hapticService = HapticService()

    init() {
        NotificationService.shared.requestAuthorizationIfNeeded()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CalculationRecord.self,
            ExchangeRate.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NumoTabView()
                .environment(appState)
                .environment(hapticService)
        }
        .modelContainer(sharedModelContainer)
    }
}
