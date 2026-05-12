import Foundation

enum SessionType: String, Codable, CaseIterable, Identifiable {
    case focus       = "focus"
    case shortBreak  = "short_break"
    case longBreak   = "long_break"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .focus:      "Focus"
        case .shortBreak: "Short Break"
        case .longBreak:  "Long Break"
        }
    }

    var shortName: String {
        switch self {
        case .focus:      "FOCUS"
        case .shortBreak: "BREAK"
        case .longBreak:  "LONG BREAK"
        }
    }

    var emoji: String {
        switch self {
        case .focus:      "🍅"
        case .shortBreak: "☕"
        case .longBreak:  "🌿"
        }
    }

    var systemImage: String {
        switch self {
        case .focus:      "flame.fill"
        case .shortBreak: "cup.and.saucer.fill"
        case .longBreak:  "leaf.fill"
        }
    }

    var isBreak: Bool {
        self == .shortBreak || self == .longBreak
    }
}
