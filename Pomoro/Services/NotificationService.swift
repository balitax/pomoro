//
//  NotificationService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
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

        let lang = Language.shared.notifications
        let content = UNMutableNotificationContent()
        content.sound = .default

        switch sessionType {
        case .focus:
            content.title = lang.focusComplete
            content.body  = lang.focusBody
            content.categoryIdentifier = "FOCUS_COMPLETE"
        case .shortBreak:
            content.title = lang.breakOver
            content.body  = lang.breakBody
        case .longBreak:
            content.title = lang.longBreakDone
            content.body  = lang.longBreakBody
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
        let lang = Language.shared.notifications
        let content = UNMutableNotificationContent()
        content.title = lang.breakReminder
        content.body  = lang.breakReminderBody
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
