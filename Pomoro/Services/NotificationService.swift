//
//  NotificationService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()
    private let sessionEndID = "pomoro.session.end"
    private let breakReminderID = "pomoro.break.reminder"

    // MARK: - Schedule

    func scheduleSessionEnd(sessionType: SessionType, timeRemaining: TimeInterval) {
        cancelPending()
        guard timeRemaining > 0 else { return }

        let content = UNMutableNotificationContent()
        content.sound = .default

        switch sessionType {
        case .focus:
            content.title = "Focus Session Complete 🍅"
            content.body  = "Great work! Time for a break."
            content.categoryIdentifier = "FOCUS_COMPLETE"
        case .shortBreak:
            content.title = "Break Over ☕"
            content.body  = "Ready to focus again?"
        case .longBreak:
            content.title = "Long Break Done 🌿"
            content.body  = "Feeling refreshed? Let's get back to it!"
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeRemaining,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: sessionEndID,
            content: content,
            trigger: trigger
        )
        center.add(request) { _ in }
    }

    func scheduleBreakReminder(after delay: TimeInterval = 300) {
        let content = UNMutableNotificationContent()
        content.title = "Still taking a break?"
        content.body  = "Tap to start your next focus session."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: breakReminderID, content: content, trigger: trigger)
        center.add(request) { _ in }
    }

    func cancelPending() {
        center.removePendingNotificationRequests(withIdentifiers: [sessionEndID, breakReminderID])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
}
