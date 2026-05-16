//
//  SessionType.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation

enum SessionType: String, Codable, CaseIterable, Identifiable {
    case focus       = "focus"
    case shortBreak  = "short_break"
    case longBreak   = "long_break"

    var id: String { rawValue }

    var displayName: String {
        Language.shared.session.displayName(for: self)
    }

    var shortName: String {
        Language.shared.session.shortName(for: self)
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
