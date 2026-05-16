//
//  FocusModeView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import ComposableArchitecture

struct FocusModeView: View {
    @Bindable var store: StoreOf<FocusFeature>
    @Binding var isPresented: Bool
    @Environment(TaskViewModel.self) private var taskVM

    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var backgroundPhase: Double = 0

    var body: some View {
        ZStack {
            focusBackground
                .ignoresSafeArea()
                .onTapGesture { showControlsTemporarily() }

            VStack(spacing: PDS.Spacing.xl) {
                Spacer()

                Text(store.currentSession.shortName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(store.currentSession.color.opacity(0.8))

                Text(store.timeDisplayString)
                    .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(PDS.Animation.fast, value: store.timeDisplayString)

                if let task = taskVM.selectedTask {
                    Text(task.title)
                        .font(PDS.Typography.callout)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                if showControls {
                    focusControls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding()

            if showControls {
                VStack {
                    HStack {
                        Button {
                            withAnimation(PDS.Animation.smooth) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .animation(PDS.Animation.smooth, value: showControls)
        .onAppear {
            scheduleControlsHide()
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: true)) {
                backgroundPhase = 1
            }
        }
        .onDisappear { controlsTimer?.invalidate() }
        #if os(iOS)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        #endif
    }

    private var focusBackground: some View {
        ZStack {
            Color(hex: "#070709")
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(store.currentSession.color.opacity(0.08 + Double(i) * 0.03))
                    .frame(width: 300 + CGFloat(i * 80))
                    .offset(
                        x: CGFloat(sin(backgroundPhase * .pi + Double(i) * 1.2)) * 60,
                        y: CGFloat(cos(backgroundPhase * .pi + Double(i) * 0.8)) * 80
                    )
                    .blur(radius: 60 + CGFloat(i * 20))
                    .animation(.easeInOut(duration: 4 + Double(i)).repeatForever(autoreverses: true), value: backgroundPhase)
            }
        }
    }

    private var focusControls: some View {
        HStack(spacing: PDS.Spacing.xl) {
            focusControlButton(systemImage: "arrow.counterclockwise") {
                store.send(.resetTapped)
            }
            Button {
                switch store.timerState {
                case .idle: store.send(.startTapped)
                case .running: store.send(.pauseTapped)
                case .paused: store.send(.resumeTapped)
                case .completed: store.send(.resetTapped)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(store.currentSession.color)
                        .frame(width: 80, height: 80)
                        .shadow(color: store.currentSession.color.opacity(0.5), radius: 20)
                    Image(systemName: store.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            focusControlButton(systemImage: "forward.end.fill") {
                store.send(.skipTapped)
            }
        }
        .padding(.bottom, PDS.Spacing.xxl)
    }

    private func focusControlButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(.white.opacity(0.1))
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func showControlsTemporarily() {
        withAnimation { showControls = true }
        scheduleControlsHide()
    }

    private func scheduleControlsHide() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            withAnimation { showControls = false }
        }
    }
}

#Preview {
    FocusModeView(
        store: Store(initialState: FocusFeature.State()) { FocusFeature() },
        isPresented: .constant(true)
    )
    .environment(TaskViewModel())
}
