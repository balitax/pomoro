//
//  Strings+Session.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Session

struct SessionStrings: StringsBase {
    let language: LanguageOption

    var focus: String { localized("Focus", "Fokus") }
    var shortBreak: String { localized("Short Break", "Istirahat Singkat") }
    var longBreak: String { localized("Long Break", "Istirahat Panjang") }
    var focusShort: String { localized("FOCUS", "FOKUS") }
    var breakShort: String { localized("BREAK", "ISTIRAHAT") }
    var longBreakShort: String { localized("LONG BREAK", "ISTIRAHAT PANJANG") }

    func displayName(for session: SessionType) -> String {
        switch session {
        case .focus:      focus
        case .shortBreak: shortBreak
        case .longBreak:  longBreak
        }
    }

    func shortName(for session: SessionType) -> String {
        switch session {
        case .focus:      focusShort
        case .shortBreak: breakShort
        case .longBreak:  longBreakShort
        }
    }
}

// MARK: - Ambient Sound Names

struct AmbientStrings: StringsBase {
    let language: LanguageOption
    var none: String { localized("None", "Tidak Ada") }
    var rain: String { localized("Rain", "Hujan") }
    var forest: String { localized("Forest", "Hutan") }
    var cafe: String { localized("Café", "Kafe") }
    var oceanWaves: String { localized("Ocean Waves", "Ombak Laut") }
    var fireplace: String { localized("Fireplace", "Perapian") }

    func displayName(for sound: AmbientSound) -> String {
        switch sound {
        case .none:   none
        case .rain:   rain
        case .forest: forest
        case .cafe:   cafe
        case .waves:  oceanWaves
        case .fire:   fireplace
        }
    }
}
