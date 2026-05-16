//
//  SoundClient.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Dependencies

struct SoundClient {
    var playSessionStart: @Sendable (SessionType) async -> Void
    var playSessionComplete: @Sendable (SessionType) async -> Void
    var startAmbient: @Sendable (AmbientSound) async -> Void
    var stopAmbient: @Sendable () async -> Void
    var startTicking: @Sendable () async -> Void
    var stopTicking: @Sendable () async -> Void
}

extension SoundClient: DependencyKey {
    static let liveValue = SoundClient(
        playSessionStart: { session in await MainActor.run { SoundService.shared.playSessionStart(session: session) } },
        playSessionComplete: { session in await MainActor.run { SoundService.shared.playSessionComplete(session: session) } },
        startAmbient: { sound in await MainActor.run { SoundService.shared.startAmbient(sound) } },
        stopAmbient: { await MainActor.run { SoundService.shared.stopAmbient() } },
        startTicking: { await MainActor.run { SoundService.shared.startTicking() } },
        stopTicking: { await MainActor.run { SoundService.shared.stopTicking() } }
    )
}

extension DependencyValues {
    var soundClient: SoundClient {
        get { self[SoundClient.self] }
        set { self[SoundClient.self] = newValue }
    }
}
