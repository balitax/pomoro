//
//  LiveActivityManager.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

#if os(iOS)
import Foundation
import ActivityKit
import SwiftUI

// MARK: - Live Activity Manager

@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.endOnAppTermination()
        }
    }

    private var activity: Activity<PomoroActivityAttributes>?
    private var currentSessionType: String = "focus"
    private var currentTaskTitle: String = ""

    func start(taskTitle: String, session: SessionType, duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        currentSessionType = session.rawValue
        currentTaskTitle   = taskTitle

        let attributes = PomoroActivityAttributes(taskTitle: taskTitle)
        let state = PomoroActivityAttributes.ContentState(
            timeRemaining: duration,
            totalTime: duration,
            sessionType: session.rawValue,
            isRunning: true,
            taskTitle: taskTitle
        )

        let endDate = Date().addingTimeInterval(duration)

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endDate),
                pushType: nil
            )
        } catch {
            print("[LiveActivityManager] Failed to start: \(error.localizedDescription)")
        }
    }

    func update(timeRemaining: TimeInterval, totalTime: TimeInterval, isRunning: Bool) {
        guard let activity else { return }
        let state = PomoroActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            sessionType: currentSessionType,
            isRunning: isRunning,
            taskTitle: currentTaskTitle
        )
        let staleDate = Date().addingTimeInterval(timeRemaining)
        Task {
            await activity.update(.init(state: state, staleDate: staleDate))
        }
    }

    func end() {
        let current = activity
        activity = nil
        Task {
            await current?.end(nil, dismissalPolicy: .immediate)
        }
    }

    func endOnAppTermination() {
        let current = activity
        activity = nil
        Task {
            await current?.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#endif
