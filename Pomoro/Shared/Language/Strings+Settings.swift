//
//  Strings+Settings.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Settings

struct SettingsStrings: StringsBase {
    let language: LanguageOption

    var title: String { localized("Settings", "Pengaturan") }
    var timer: String { localized("Timer", "Timer") }
    var focusDuration: String { localized("Focus Duration", "Durasi Fokus") }
    var shortBreak: String { localized("Short Break", "Istirahat Singkat") }
    var longBreak: String { localized("Long Break", "Istirahat Panjang") }
    var sessionsBeforeLongBreak: String { localized("Sessions Before Long Break", "Sesi Sebelum Istirahat Panjang") }
    var dailyGoal: String { localized("Daily Goal", "Target Harian") }
    var behavior: String { localized("Behavior", "Perilaku") }
    var autoStartBreaks: String { localized("Auto-start Breaks", "Mulai Otomatis Istirahat") }
    var autoStartFocus: String { localized("Auto-start Focus", "Mulai Otomatis Fokus") }
    var soundAndHaptics: String { localized("Sound & Haptics", "Suara & Haptik") }
    var sessionSounds: String { localized("Session Sounds", "Suara Sesi") }
    var tickingSound: String { localized("Ticking Sound", "Suara Detak") }
    var hapticFeedback: String { localized("Haptic Feedback", "Umpan Balik Haptik") }
    var ambientSound: String { localized("Ambient Sound", "Suara Ambient") }
    var appearance: String { localized("Appearance", "Tampilan") }
    var system: String { localized("System", "Sistem") }
    var light: String { localized("Light", "Terang") }
    var dark: String { localized("Dark", "Gelap") }
    var motivationalMessages: String { localized("Motivational Messages", "Pesan Motivasi") }
    var notifications: String { localized("Notifications", "Notifikasi") }
    var sessionComplete: String { localized("Session Complete", "Sesi Selesai") }
    var breakReminders: String { localized("Break Reminders", "Pengingat Istirahat") }
    var about: String { localized("About", "Tentang") }
    var version: String { localized("Version", "Versi") }
    var appVersion: String { localized("1.0.0", "1.0.0") }
    var privacyPolicy: String { localized("Privacy Policy", "Kebijakan Privasi") }
    var support: String { localized("Support", "Dukungan") }
    var languageSetting: String { localized("Language", "Bahasa") }
    var min: String { localized("min", "menit") }

    func durationLabel(_ value: Int) -> String {
        language == .english ? "\(value) min" : "\(value) menit"
    }
}
