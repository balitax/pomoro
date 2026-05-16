//
//  SoundService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation
import AVFoundation

final class SoundService {
    static let shared = SoundService()
    private init() {}

    private var player: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var tickPlayer: AVAudioPlayer?

    private let settings = AppSettings.shared

    // MARK: - Session Events

    func playSessionStart(session: SessionType) {
        guard settings.soundEnabled else { return }
        playSystemSound(session.isBreak ? "break_start" : "focus_start")
    }

    func playSessionComplete(session: SessionType) {
        guard settings.soundEnabled else { return }
        playSystemSound("session_complete")
    }

    // MARK: - Ambient Sound

    func startAmbient(_ sound: AmbientSound) {
        stopAmbient()
        guard sound != .none, let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.numberOfLoops = -1
            ambientPlayer?.volume = 0.4
            ambientPlayer?.play()
        } catch {}
    }

    func stopAmbient() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }

    // MARK: - Ticking

    func startTicking() {
        guard settings.tickingEnabled else { return }
        guard let url = Bundle.main.url(forResource: "tick", withExtension: "mp3") else { return }
        do {
            tickPlayer = try AVAudioPlayer(contentsOf: url)
            tickPlayer?.numberOfLoops = -1
            tickPlayer?.volume = 0.2
            tickPlayer?.play()
        } catch {}
    }

    func stopTicking() {
        tickPlayer?.stop()
        tickPlayer = nil
    }

    // MARK: - Private

    private func playSystemSound(_ named: String) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "wav") else {
            // Fallback: system sound
            #if os(iOS)
            AudioServicesPlaySystemSound(1052)
            #endif
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {}
    }
}

#if os(iOS)
import AudioToolbox
#endif
