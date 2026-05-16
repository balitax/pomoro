//
//  HapticService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation

enum HapticIntensity { case light, medium, heavy }
enum HapticNotification { case success, warning, error }

// MARK: - Haptic Service

final class HapticService {
    static let shared = HapticService()
    private init() {}

    func impact(_ intensity: HapticIntensity) {
        #if os(iOS)
        let style: _ImpactStyle = {
            switch intensity {
            case .light:  .light
            case .medium: .medium
            case .heavy:  .heavy
            }
        }()
        _doImpact(style)
        #endif
    }

    func notification(_ style: HapticNotification) {
        #if os(iOS)
        let type: _NotifType = {
            switch style {
            case .success: .success
            case .warning: .warning
            case .error:   .error
            }
        }()
        _doNotification(type)
        #endif
    }

    func selection() {
        #if os(iOS)
        _doSelection()
        #endif
    }
}

// Private iOS shims to avoid importing UIKit at top-level in shared code
#if os(iOS)
import UIKit

private typealias _ImpactStyle = UIImpactFeedbackGenerator.FeedbackStyle
private typealias _NotifType   = UINotificationFeedbackGenerator.FeedbackType

private func _doImpact(_ style: _ImpactStyle) {
    let g = UIImpactFeedbackGenerator(style: style)
    g.prepare(); g.impactOccurred()
}

private func _doNotification(_ type: _NotifType) {
    let g = UINotificationFeedbackGenerator()
    g.prepare(); g.notificationOccurred(type)
}

private func _doSelection() {
    UISelectionFeedbackGenerator().selectionChanged()
}
#endif
