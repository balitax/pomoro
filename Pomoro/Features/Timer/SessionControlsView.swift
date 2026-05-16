//
//  SessionControlsView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

struct SessionControlsView: View {
    @Environment(TimerViewModel.self) private var timerVM

    var body: some View {
        HStack(spacing: PDS.Spacing.lg) {
            // Reset / Back button
            if !timerVM.isIdle {
                controlButton(
                    systemImage: "arrow.counterclockwise",
                    action: timerVM.reset
                )
                .transition(.scale.combined(with: .opacity))
            }

            // Main play/pause
            mainButton
                .frame(width: 80, height: 80)

            // Skip button
            if !timerVM.isIdle {
                controlButton(
                    systemImage: "forward.end.fill",
                    action: timerVM.skip
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(PDS.Animation.spring, value: timerVM.isIdle)
    }

    // MARK: - Main Button

    private var mainButton: some View {
        Button {
            withAnimation(PDS.Animation.spring) {
                switch timerVM.timerState {
                case .idle:    timerVM.start()
                case .running: timerVM.pause()
                case .paused:  timerVM.resume()
                case .completed: timerVM.reset()
                }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(timerVM.currentSession.color)
                    .shadow(color: timerVM.currentSession.color.opacity(0.4), radius: 16, x: 0, y: 4)

                Image(systemName: mainButtonIcon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace.downUp))
            }
        }
        .buttonStyle(ScaleButtonStyle())
        #if os(iOS)
        .sensoryFeedback(.impact(weight: .medium), trigger: timerVM.timerState)
        #endif
    }

    private var mainButtonIcon: String {
        switch timerVM.timerState {
        case .idle:       return "play.fill"
        case .running:    return "pause.fill"
        case .paused:     return "play.fill"
        case .completed:  return "arrow.counterclockwise"
        }
    }

    // MARK: - Control Button

    private func controlButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(PDS.Animation.snappy, value: configuration.isPressed)
    }
}
