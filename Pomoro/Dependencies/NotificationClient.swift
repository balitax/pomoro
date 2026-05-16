//
//  NotificationClient.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation
import Dependencies

struct NotificationClient {
    var scheduleSessionEnd: @Sendable (SessionType, TimeInterval) async -> Void
    var scheduleBreakReminder: @Sendable (TimeInterval) async -> Void
    var cancelPending: @Sendable () async -> Void
}

extension NotificationClient: DependencyKey {
    static let liveValue = NotificationClient(
        scheduleSessionEnd: { session, remaining in
            await MainActor.run { NotificationService.shared.scheduleSessionEnd(sessionType: session, timeRemaining: remaining) }
        },
        scheduleBreakReminder: { delay in
            await MainActor.run { NotificationService.shared.scheduleBreakReminder(after: delay) }
        },
        cancelPending: { await MainActor.run { NotificationService.shared.cancelPending() } }
    )
}

extension DependencyValues {
    var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
