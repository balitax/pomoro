//
//  CircularTimerView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import ComposableArchitecture

struct CircularTimerView: View {
    @Bindable var store: StoreOf<FocusFeature>

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0

    private let ringSize: CGFloat = 256
    private let lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .stroke(store.currentSession.color.opacity(0.12), lineWidth: 10)
                .frame(width: ringSize + 28, height: ringSize + 28)
                .scaleEffect(pulseScale)
                .opacity(pulseOpacity)

            Circle()
                .stroke(Color(.systemFill), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: store.progressForRing)
                .stroke(
                    LinearGradient(colors: store.currentSession.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.7), value: store.progressForRing)

            if store.progressForRing > 0 {
                let angle = CGFloat(store.progressForRing * 360 - 90) * .pi / 180
                Circle()
                    .fill(store.currentSession.color)
                    .frame(width: lineWidth, height: lineWidth)
                    .blur(radius: 3)
                    .offset(x: cos(angle) * (ringSize / 2), y: sin(angle) * (ringSize / 2))
                    .animation(.easeInOut(duration: 0.7), value: store.progressForRing)
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    switch store.timerState {
                    case .idle: store.send(.startTapped)
                    case .running: store.send(.pauseTapped)
                    case .paused: store.send(.resumeTapped)
                    case .completed: store.send(.resetTapped)
                    }
                }
            } label: {
                VStack(spacing: 10) {
                    Text(store.timeDisplayString)
                        .font(.system(size: 58, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(countsDown: true))
                        .animation(.easeInOut(duration: 0.25), value: store.timeDisplayString)
                    Image(systemName: centerIcon)
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(.secondary)
                        .contentTransition(.symbolEffect(.replace.downUp))
                        .animation(.easeInOut(duration: 0.2), value: store.timerState)
                }
            }
            .buttonStyle(SpringButtonStyle())
        }
        .frame(width: ringSize + 40, height: ringSize + 40)
        .onChange(of: store.isRunning) { _, running in
            withAnimation(
                running
                    ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.35)
            ) {
                pulseScale = running ? 1.05 : 1.0
                pulseOpacity = running ? 1.0 : 0.0
            }
        }
    }

    private var centerIcon: String {
        switch store.timerState {
        case .idle: "play.fill"
        case .running: "pause.fill"
        case .paused: "play.fill"
        case .completed: "arrow.counterclockwise"
        }
    }
}

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    CircularTimerView(
        store: Store(initialState: FocusFeature.State()) { FocusFeature() }
    )
    .padding()
}
