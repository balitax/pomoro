//
//  Strings+Notification.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Notifications

struct NotificationStrings: StringsBase {
    let language: LanguageOption

    var focusComplete: String { localized("Focus Session Complete 🍅", "Sesi Fokus Selesai 🍅") }
    var focusBody: String { localized("Great work! Time for a break.", "Kerja bagus! Waktunya istirahat.") }
    var breakOver: String { localized("Break Over ☕", "Istirahat Selesai ☕") }
    var breakBody: String { localized("Ready to focus again?", "Siap fokus lagi?") }
    var longBreakDone: String { localized("Long Break Done 🌿", "Istirahat Panjang Selesai 🌿") }
    var longBreakBody: String { localized("Feeling refreshed? Let's get back to it!", "Sudah segar? Ayo kembali!") }
    var breakReminder: String { localized("Still taking a break?", "Masih istirahat?") }
    var breakReminderBody: String { localized("Tap to start your next focus session.", "Ketuk untuk memulai sesi fokus berikutnya.") }

    func title(for session: SessionType) -> String {
        switch session {
        case .focus:      focusComplete
        case .shortBreak: breakOver
        case .longBreak:  longBreakDone
        }
    }

    func body(for session: SessionType) -> String {
        switch session {
        case .focus:      focusBody
        case .shortBreak: breakBody
        case .longBreak:  longBreakBody
        }
    }
}
