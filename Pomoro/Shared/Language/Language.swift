//
//  Language.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Observation
import Foundation

// MARK: - Language Option

enum LanguageOption: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case indonesian = "id"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:   "English"
        case .indonesian: "Bahasa Indonesia"
        }
    }
}

// MARK: - Strings Base

protocol StringsBase {
    var language: LanguageOption { get }
}

extension StringsBase {
    func localized(_ en: String, _ id: String) -> String {
        language == .english ? en : id
    }
}

// MARK: - Language Root

@Observable
final class Language {
    var current: LanguageOption {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "appLanguage") }
    }

    init() {
        current = UserDefaults.standard.string(forKey: "appLanguage")
            .flatMap(LanguageOption.init(rawValue:)) ?? .english
    }

    static let shared = Language()

    var common: CommonStrings { CommonStrings(language: current) }
    var tabs: TabStrings { TabStrings(language: current) }
    var onboarding: OnboardingStrings { OnboardingStrings(language: current) }
    var signIn: SignInStrings { SignInStrings(language: current) }
    var session: SessionStrings { SessionStrings(language: current) }
    var timer: TimerStrings { TimerStrings(language: current) }
    var tasks: TaskStrings { TaskStrings(language: current) }
    var statistics: StatisticsStrings { StatisticsStrings(language: current) }
    var settings: SettingsStrings { SettingsStrings(language: current) }
    var info: InfoStrings { InfoStrings(language: current) }
    var ambient: AmbientStrings { AmbientStrings(language: current) }
    var notifications: NotificationStrings { NotificationStrings(language: current) }
    var liveActivity: LiveActivityStrings { LiveActivityStrings(language: current) }
    var appIntents: AppIntentStrings { AppIntentStrings(language: current) }
}
