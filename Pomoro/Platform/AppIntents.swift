//
//  AppIntents.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import AppIntents
import SwiftUI

// MARK: - Start Timer Intent

struct StartPomoroIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Pomoro Timer"
    static var description = IntentDescription("Start a focus session.")
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Notify the app via shared state
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "intentStartTimer")
        return .result(value: "Timer started!")
    }
}

// MARK: - Pause Timer Intent

struct PausePomoroIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause Pomoro Timer"
    static var description = IntentDescription("Pause the current focus session.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "intentPauseTimer")
        return .result(value: "Timer paused!")
    }
}

// MARK: - Skip Session Intent

struct SkipPomoroSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Skip Pomoro Session"
    static var description = IntentDescription("Skip the current session and advance.")

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        UserDefaults(suiteName: appGroupID)?.set(true, forKey: "intentSkipSession")
        return .result(value: "Session skipped!")
    }
}

// MARK: - Shortcuts Provider

struct PomoroShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartPomoroIntent(),
            phrases: [
                "Start \(.applicationName)",
                "Start focus timer in \(.applicationName)",
                "Begin pomodoro in \(.applicationName)"
            ],
            shortTitle: "Start Timer",
            systemImageName: "timer"
        )
        AppShortcut(
            intent: PausePomoroIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "Pause timer in \(.applicationName)"
            ],
            shortTitle: "Pause Timer",
            systemImageName: "pause.circle"
        )
        AppShortcut(
            intent: SkipPomoroSessionIntent(),
            phrases: [
                "Skip session in \(.applicationName)"
            ],
            shortTitle: "Skip Session",
            systemImageName: "forward.end"
        )
    }
}
