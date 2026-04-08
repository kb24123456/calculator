//
//  HapticService.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import UIKit

@Observable
final class HapticService {
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "numo_haptic_enabled") as? Bool ?? true
    }

    init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }

    func numberKey() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.6)
    }

    func operatorKey() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.8)
    }

    func equalsKey() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred(intensity: 0.9)
    }

    func clearKey() {
        guard isEnabled else { return }
        rigidGenerator.impactOccurred(intensity: 0.5)
    }

    func toolSwitch() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred(intensity: 0.5)
    }

    func copySuccess() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
}
