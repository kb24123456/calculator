//
//  calculatorApp.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import SwiftUI
import SwiftData

@main
struct NumoApp: App {
    @State private var appState = AppState()
    @State private var hapticService = HapticService()
    @State private var settingsStore = SettingsStore()
    @AppStorage("numo_has_seen_onboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

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
            ZStack {
                NumoTabView()
                    .environment(appState)
                    .environment(hapticService)
                    .environment(settingsStore)

                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(settingsStore.preferredColorScheme)
            .onAppear {
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
            }
            .onChange(of: showOnboarding) { _, newValue in
                if !newValue {
                    hasSeenOnboarding = true
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
