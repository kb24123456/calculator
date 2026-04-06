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

    init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }

    func numberKey() {
        lightGenerator.impactOccurred(intensity: 0.6)
    }

    func operatorKey() {
        lightGenerator.impactOccurred(intensity: 0.8)
    }

    func equalsKey() {
        mediumGenerator.impactOccurred(intensity: 0.9)
    }

    func clearKey() {
        rigidGenerator.impactOccurred(intensity: 0.5)
    }

    func toolSwitch() {
        lightGenerator.impactOccurred(intensity: 0.5)
    }

    func copySuccess() {
        notificationGenerator.notificationOccurred(.success)
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
}
