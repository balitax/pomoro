//
//  WidgetSharedData.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation
import WidgetKit
#if canImport(ActivityKit)
import ActivityKit
#endif

// MARK: - Live Activity Attributes (shared between App and Widget)

#if canImport(ActivityKit)
struct PomoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var totalTime: TimeInterval
        var sessionType: String   // "focus" | "short_break" | "long_break"
        var isRunning: Bool
        var taskTitle: String

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
#endif

// MARK: - Shared data between App and Widget via App Group

let appGroupID = "group.com.gus.pomoro"

struct WidgetTimerEntry: TimelineEntry {
    let date: Date
    let sessionType: String
    let timeRemaining: TimeInterval
    let totalTime: TimeInterval
    let isRunning: Bool
    let completedToday: Int

    static let placeholder = WidgetTimerEntry(
        date: Date(),
        sessionType: "focus",
        timeRemaining: 25 * 60,
        totalTime: 25 * 60,
        isRunning: false,
        completedToday: 3
    )

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

// MARK: - Widget Data Store

final class WidgetDataStore {
    static let shared = WidgetDataStore()

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    func save(entry: WidgetTimerEntry) {
        defaults?.set(entry.sessionType, forKey: "sessionType")
        defaults?.set(entry.timeRemaining, forKey: "timeRemaining")
        defaults?.set(entry.totalTime, forKey: "totalTime")
        defaults?.set(entry.isRunning, forKey: "isRunning")
        defaults?.set(entry.completedToday, forKey: "completedToday")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func load() -> WidgetTimerEntry {
        guard let defaults else { return .placeholder }
        return WidgetTimerEntry(
            date: Date(),
            sessionType: defaults.string(forKey: "sessionType") ?? "focus",
            timeRemaining: defaults.double(forKey: "timeRemaining"),
            totalTime: defaults.double(forKey: "totalTime"),
            isRunning: defaults.bool(forKey: "isRunning"),
            completedToday: defaults.integer(forKey: "completedToday")
        )
    }
}
