//
//  NotificationManager.swift
//  Pomodo
//
//  Handles local notifications for timer completion
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Schedule Notifications
    func scheduleTimerCompletion(in seconds: TimeInterval, sessionType: SessionType) {
        let content = UNMutableNotificationContent()

        switch sessionType {
        case .work:
            content.title = "Work Session Complete!"
            content.body = "Great job! Time for a break."
            content.sound = .default
        case .shortBreak:
            content.title = "Break Over"
            content.body = "Ready to get back to work?"
            content.sound = .default
        case .longBreak:
            content.title = "Long Break Over"
            content.body = "Feeling refreshed? Let's continue!"
            content.sound = .default
        }

        content.categoryIdentifier = "TIMER_COMPLETE"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "timerComplete",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    // MARK: - Cancel Notifications
    func cancelPendingNotifications() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["timerComplete"])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
