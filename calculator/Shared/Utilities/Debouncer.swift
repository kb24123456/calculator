//
//  Debouncer.swift
//  calculator
//
//  Created by 廖云丰 on 2026/4/6.
//

import Foundation

@Observable
final class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: Duration

    init(delay: Duration = .milliseconds(100)) {
        self.delay = delay
    }

    func debounce(action: @escaping @Sendable () async -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            await action()
        }
    }
}
