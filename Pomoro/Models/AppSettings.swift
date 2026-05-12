import Foundation
import SwiftUI
import Combine

/// App-wide settings stored in AppStorage / UserDefaults
final class AppSettings: ObservableObject {

    // MARK: - Timer Durations (minutes)
    @AppStorage("focusDuration")     var focusDuration: Double    = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Double = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Double = 15
    @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4

    // MARK: - Behavior
    @AppStorage("autoStartBreaks")   var autoStartBreaks: Bool    = false
    @AppStorage("autoStartFocus")    var autoStartFocus: Bool     = false
    @AppStorage("skipBreaksAllowed") var skipBreaksAllowed: Bool  = true

    // MARK: - Sound & Haptics
    @AppStorage("tickingEnabled")    var tickingEnabled: Bool     = false
    @AppStorage("soundEnabled")      var soundEnabled: Bool       = true
    @AppStorage("hapticEnabled")     var hapticEnabled: Bool      = true
    @AppStorage("selectedAmbient")   var selectedAmbient: String  = AmbientSound.none.rawValue

    // MARK: - Appearance
    @AppStorage("colorSchemeRaw")    var colorSchemeRaw: Int      = 0   // 0=system, 1=light, 2=dark
    @AppStorage("showMotivation")    var showMotivation: Bool     = true

    // MARK: - Notifications
    @AppStorage("notifyOnComplete")  var notifyOnComplete: Bool   = true
    @AppStorage("notifyBreak")       var notifyBreak: Bool        = true

    // MARK: - Computed

    var focusDurationSeconds: TimeInterval    { focusDuration * 60 }
    var shortBreakSeconds: TimeInterval       { shortBreakDuration * 60 }
    var longBreakSeconds: TimeInterval        { longBreakDuration * 60 }

    var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case 1: return .light
        case 2: return .dark
        default: return nil
        }
    }

    var selectedAmbientSound: AmbientSound {
        AmbientSound(rawValue: selectedAmbient) ?? .none
    }

    func duration(for sessionType: SessionType) -> TimeInterval {
        switch sessionType {
        case .focus:      focusDurationSeconds
        case .shortBreak: shortBreakSeconds
        case .longBreak:  longBreakSeconds
        }
    }

    static let shared = AppSettings()
}

// MARK: - Ambient Sound

enum AmbientSound: String, CaseIterable, Identifiable {
    case none     = "none"
    case rain     = "rain"
    case forest   = "forest"
    case cafe     = "cafe"
    case waves    = "waves"
    case fire     = "fire"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:   "None"
        case .rain:   "Rain"
        case .forest: "Forest"
        case .cafe:   "Café"
        case .waves:  "Ocean Waves"
        case .fire:   "Fireplace"
        }
    }

    var systemImage: String {
        switch self {
        case .none:   "speaker.slash.fill"
        case .rain:   "cloud.rain.fill"
        case .forest: "tree.fill"
        case .cafe:   "cup.and.saucer.fill"
        case .waves:  "water.waves"
        case .fire:   "flame.fill"
        }
    }
}
