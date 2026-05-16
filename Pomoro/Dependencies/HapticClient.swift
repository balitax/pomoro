//
//  HapticClient.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Dependencies

struct HapticClient {
    var impact: @Sendable (HapticIntensity) async -> Void
    var notification: @Sendable (HapticNotification) async -> Void
    var selection: @Sendable () async -> Void
}

extension HapticClient: DependencyKey {
    static let liveValue = HapticClient(
        impact: { intensity in await MainActor.run { HapticService.shared.impact(intensity) } },
        notification: { style in await MainActor.run { HapticService.shared.notification(style) } },
        selection: { await MainActor.run { HapticService.shared.selection() } }
    )
}

extension DependencyValues {
    var hapticClient: HapticClient {
        get { self[HapticClient.self] }
        set { self[HapticClient.self] = newValue }
    }
}
