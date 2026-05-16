//
//  CircularTimerView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

struct CircularTimerView: View {
    @Environment(TimerViewModel.self) private var timerVM

    @State private var pulseScale:   CGFloat = 1.0
    @State private var pulseOpacity: Double  = 0

    private let ringSize:  CGFloat = 256
    private let lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            // Outer pulse ring — breathes when running
            Circle()
                .stroke(timerVM.currentSession.color.opacity(0.12), lineWidth: 10)
                .frame(width: ringSize + 28, height: ringSize + 28)
                .scaleEffect(pulseScale)
                .opacity(pulseOpacity)

            // Track ring
            Circle()
                .stroke(Color(.systemFill),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)

            // Progress ring
            Circle()
                .trim(from: 0, to: timerVM.progressForRing)
                .stroke(
                    LinearGradient(
                        colors: timerVM.currentSession.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.7), value: timerVM.progressForRing)

            // Tip glow dot
            if timerVM.progressForRing > 0 {
                tipGlow
            }

            // Center — tap to play/pause
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    switch timerVM.timerState {
                    case .idle:      timerVM.start()
                    case .running:   timerVM.pause()
                    case .paused:    timerVM.resume()
                    case .completed: timerVM.reset()
                    }
                }
            } label: {
                VStack(spacing: 10) {
                    Text(timerVM.timeDisplayString)
                        .font(.system(size: 58, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.easeInOut(duration: 0.25), value: timerVM.timeDisplayString)

                    Image(systemName: centerIcon)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(.secondary)
                        .contentTransition(.symbolEffect(.replace.downUp))
                        .animation(.easeInOut(duration: 0.2), value: timerVM.timerState)
                }
            }
            .buttonStyle(SpringButtonStyle())
        }
        .frame(width: ringSize + 40, height: ringSize + 40)
        .onChange(of: timerVM.isRunning) { _, running in
            withAnimation(
                running
                    ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.35)
            ) {
                pulseScale   = running ? 1.05 : 1.0
                pulseOpacity = running ? 1.0  : 0.0
            }
        }
    }

    // MARK: - Tip Glow

    private var tipGlow: some View {
        let angle   = CGFloat(timerVM.progressForRing * 360 - 90) * .pi / 180
        let radius  = ringSize / 2
        return Circle()
            .fill(timerVM.currentSession.color)
            .frame(width: lineWidth, height: lineWidth)
            .blur(radius: 3)
            .offset(x: cos(angle) * radius, y: sin(angle) * radius)
            .animation(.easeInOut(duration: 0.7), value: timerVM.progressForRing)
    }

    private var centerIcon: String {
        switch timerVM.timerState {
        case .idle:      "play.fill"
        case .running:   "pause.fill"
        case .paused:    "play.fill"
        case .completed: "arrow.counterclockwise"
        }
    }
}

// MARK: - Spring Button Style

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    CircularTimerView()
        .environment(TimerViewModel())
        .padding()
}
