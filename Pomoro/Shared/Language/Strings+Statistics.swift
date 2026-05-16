//
//  Strings+Statistics.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Statistics

struct StatisticsStrings: StringsBase {
    let language: LanguageOption

    var title: String { localized("Statistics", "Statistik") }
    var today: String { localized("Today", "Hari Ini") }
    var focusTime: String { localized("Focus Time", "Waktu Fokus") }
    var dayStreak: String { localized("Day Streak", "Rangkaian Hari") }
    var dailyGoal: String { localized("Daily Goal", "Target Harian") }
    var goalReached: String { localized("Goal reached! 🎉", "Target tercapai! 🎉") }
    var thisWeek: String { localized("This Week", "Minggu Ini") }
    var allTime: String { localized("All Time", "Semua Waktu") }
    var pomodoros: String { localized("Pomodoros", "Pomodoro") }
    var dailyAvg: String { localized("Daily Avg", "Rata-rata Harian") }

    func sessionsToGo(_ count: Int) -> String {
        language == .english ? "\(count) sessions to go" : "\(count) sesi lagi"
    }
}
