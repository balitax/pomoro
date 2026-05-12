#if os(iOS)
import Foundation
import ActivityKit
import SwiftUI

// MARK: - Live Activity Attributes

struct PomoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var totalTime: TimeInterval
        var sessionType: String
        var isRunning: Bool

        var progress: Double {
            guard totalTime > 0 else { return 0 }
            return 1.0 - (timeRemaining / totalTime)
        }

        var timeDisplayString: String {
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    var taskTitle: String
}

// MARK: - Live Activity Manager

@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    private init() {}

    private var activity: Activity<PomoroActivityAttributes>?

    func start(taskTitle: String, session: SessionType, duration: TimeInterval) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = PomoroActivityAttributes(taskTitle: taskTitle)
        let state = PomoroActivityAttributes.ContentState(
            timeRemaining: duration,
            totalTime: duration,
            sessionType: session.rawValue,
            isRunning: true
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {}
    }

    func update(timeRemaining: TimeInterval, totalTime: TimeInterval, isRunning: Bool) {
        guard let activity else { return }
        let state = PomoroActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            sessionType: activity.attributes.taskTitle,
            isRunning: isRunning
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end() {
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
            activity = nil
        }
    }
}
#endif
