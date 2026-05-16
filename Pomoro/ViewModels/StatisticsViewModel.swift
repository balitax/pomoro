//
//  StatisticsViewModel.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation
import SwiftUI
import SwiftData
import Charts

@Observable
final class StatisticsViewModel {

    var sessions: [PomodoroSession] = []
    private let settings = AppSettings.shared

    // MARK: - Computed Stats

    var totalFocusToday: TimeInterval {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions
            .filter { $0.type == .focus && $0.wasCompleted && $0.startedAt >= today }
            .reduce(0) { $0 + $1.actualDuration }
    }

    var totalFocusTodayFormatted: String {
        formatDuration(totalFocusToday)
    }

    var completedTodayCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions.filter {
            $0.type == .focus && $0.wasCompleted && $0.startedAt >= today
        }.count
    }

    var dailyGoal: Int { settings.dailyGoal }

    var dailyGoalProgress: Double {
        guard settings.dailyGoal > 0 else { return 0 }
        return min(1.0, Double(completedTodayCount) / Double(settings.dailyGoal))
    }

    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        // If today has no completed session yet, start streak check from yesterday
        // so we don't penalise users who haven't started today yet.
        let todayStart = calendar.startOfDay(for: Date())
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart)!
        let todayDone = sessions.contains {
            $0.type == .focus && $0.wasCompleted &&
            $0.startedAt >= todayStart && $0.startedAt < tomorrowStart
        }
        var date = todayDone ? todayStart : calendar.date(byAdding: .day, value: -1, to: todayStart)!

        while true {
            let dayStart = date
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            let hasSession = sessions.contains {
                $0.type == .focus && $0.wasCompleted &&
                $0.startedAt >= dayStart && $0.startedAt < dayEnd
            }
            if hasSession {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
        }
        return streak
    }

    var weeklyData: [DayData] {
        let calendar = Calendar.current
        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let count = sessions.filter {
                $0.type == .focus && $0.wasCompleted &&
                $0.startedAt >= dayStart && $0.startedAt < dayEnd
            }.count

            let totalMins = sessions.filter {
                $0.type == .focus && $0.wasCompleted &&
                $0.startedAt >= dayStart && $0.startedAt < dayEnd
            }.reduce(0.0) { $0 + $1.actualDuration / 60 }

            return DayData(
                date: date,
                pomodoroCount: count,
                focusMinutes: totalMins
            )
        }
    }

    var totalAllTime: Int {
        sessions.filter { $0.type == .focus && $0.wasCompleted }.count
    }

    var averageDailyFocus: String {
        let days = max(1, Set(sessions.map { $0.dayString }).count)
        let total = sessions
            .filter { $0.type == .focus && $0.wasCompleted }
            .reduce(0.0) { $0 + $1.actualDuration }
        return formatDuration(total / Double(days))
    }

    func load(sessions: [PomodoroSession]) {
        self.sessions = sessions
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Chart Data Model

struct DayData: Identifiable {
    let id = UUID()
    let date: Date
    let pomodoroCount: Int
    let focusMinutes: Double

    var dayLabel: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE"
        return fmt.string(from: date)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}
