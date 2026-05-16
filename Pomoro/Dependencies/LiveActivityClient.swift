//
//  LiveActivityClient.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation
import Dependencies

struct LiveActivityClient {
    var start: @Sendable (String, SessionType, TimeInterval) async -> Void
    var update: @Sendable (TimeInterval, TimeInterval, Bool) async -> Void
    var end: @Sendable () async -> Void
}

extension LiveActivityClient: DependencyKey {
    static let liveValue = LiveActivityClient(
        start: { title, session, duration in
            #if os(iOS)
            await MainActor.run { LiveActivityManager.shared.start(taskTitle: title, session: session, duration: duration) }
            #endif
        },
        update: { remaining, total, running in
            #if os(iOS)
            await MainActor.run { LiveActivityManager.shared.update(timeRemaining: remaining, totalTime: total, isRunning: running) }
            #endif
        },
        end: {
            #if os(iOS)
            await MainActor.run { LiveActivityManager.shared.end() }
            #endif
        }
    )
}

extension DependencyValues {
    var liveActivityClient: LiveActivityClient {
        get { self[LiveActivityClient.self] }
        set { self[LiveActivityClient.self] = newValue }
    }
}
