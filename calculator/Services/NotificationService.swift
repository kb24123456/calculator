//
//  NotificationService.swift
//  calculator
//

import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorizationIfNeeded() {
        Task {
            let settings = await center.notificationSettings()

            guard settings.authorizationStatus == .notDetermined else {
                return
            }

            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        }
    }

    func notifyCopied() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "结果已复制")

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 立即触发
        )

        center.add(request)
    }

    // 前台也展示 banner
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
