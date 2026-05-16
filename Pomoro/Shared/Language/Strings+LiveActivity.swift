//
//  Strings+LiveActivity.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Live Activity

struct LiveActivityStrings: StringsBase {
    let language: LanguageOption
    var focusSession: String { localized("Focus Session", "Sesi Fokus") }
    var shortBreak: String { localized("Short Break", "Istirahat Singkat") }
    var longBreak: String { localized("Long Break", "Istirahat Panjang") }
    var running: String { localized("Running", "Berjalan") }
    var paused: String { localized("Paused", "Dijeda") }

    func sessionName(for type: String) -> String {
        switch type {
        case "focus":       focusSession
        case "short_break": shortBreak
        default:            longBreak
        }
    }

    func statusLabel(isRunning: Bool) -> String {
        isRunning ? running : paused
    }
}

// MARK: - App Intents

struct AppIntentStrings: StringsBase {
    let language: LanguageOption

    var startTimerTitle: String { localized("Start Pomoro Timer", "Mulai Timer Pomoro") }
    var startTimerDesc: String { localized("Start a focus session.", "Mulai sesi fokus.") }
    var timerStarted: String { localized("Timer started!", "Timer dimulai!") }
    var pauseTimerTitle: String { localized("Pause Pomoro Timer", "Jeda Timer Pomoro") }
    var pauseTimerDesc: String { localized("Pause the current focus session.", "Jeda sesi fokus saat ini.") }
    var timerPaused: String { localized("Timer paused!", "Timer dijeda!") }
    var skipSessionTitle: String { localized("Skip Pomoro Session", "Lewati Sesi Pomoro") }
    var skipSessionDesc: String { localized("Skip the current session and advance.", "Lewati sesi saat ini dan lanjutkan.") }
    var sessionSkipped: String { localized("Session skipped!", "Sesi dilewati!") }
    var startShortcut: String { localized("Start Timer", "Mulai Timer") }
    var pauseShortcut: String { localized("Pause Timer", "Jeda Timer") }
    var skipShortcut: String { localized("Skip Session", "Lewati Sesi") }
}
