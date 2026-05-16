//
//  FocusModeView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

struct FocusModeView: View {
    @Binding var isPresented: Bool
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(TaskViewModel.self) private var taskVM

    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var backgroundPhase: Double = 0

    var body: some View {
        ZStack {
            // Animated background
            focusBackground
                .ignoresSafeArea()
                .onTapGesture {
                    showControlsTemporarily()
                }

            // Content
            VStack(spacing: PDS.Spacing.xl) {
                Spacer()

                // Session label
                Text(timerVM.currentSession.shortName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(timerVM.currentSession.color.opacity(0.8))

                // Large timer
                Text(timerVM.timeDisplayString)
                    .font(.system(size: 96, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(PDS.Animation.fast, value: timerVM.timeDisplayString)

                // Task label if selected
                if let task = taskVM.selectedTask {
                    Text(task.title)
                        .font(PDS.Typography.callout)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                // Controls (auto-hide)
                if showControls {
                    focusControls
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding()

            // Exit button (top left)
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
        .onDisappear {
            controlsTimer?.invalidate()
        }
        #if os(iOS)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        #endif
    }

    // MARK: - Focus Background

    private var focusBackground: some View {
        ZStack {
            Color(hex: "#070709")

            // Animated blobs
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(
                        timerVM.currentSession.color
                            .opacity(0.08 + Double(i) * 0.03)
                    )
                    .frame(width: 300 + CGFloat(i * 80))
                    .offset(
                        x: CGFloat(sin(backgroundPhase * .pi + Double(i) * 1.2)) * 60,
                        y: CGFloat(cos(backgroundPhase * .pi + Double(i) * 0.8)) * 80
                    )
                    .blur(radius: 60 + CGFloat(i * 20))
                    .animation(
                        .easeInOut(duration: 4 + Double(i)).repeatForever(autoreverses: true),
                        value: backgroundPhase
                    )
            }
        }
    }

    // MARK: - Focus Controls

    private var focusControls: some View {
        HStack(spacing: PDS.Spacing.xl) {
            // Reset
            focusControlButton(systemImage: "arrow.counterclockwise") {
                timerVM.reset()
            }

            // Main
            Button {
                switch timerVM.timerState {
                case .idle:    timerVM.start()
                case .running: timerVM.pause()
                case .paused:  timerVM.resume()
                case .completed: timerVM.reset()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(timerVM.currentSession.color)
                        .frame(width: 80, height: 80)
                        .shadow(color: timerVM.currentSession.color.opacity(0.5), radius: 20)
                    Image(systemName: timerVM.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // Skip
            focusControlButton(systemImage: "forward.end.fill") {
                timerVM.skip()
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

    // MARK: - Auto-hide Helpers

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
    FocusModeView(isPresented: .constant(true))
        .environment(TimerViewModel())
        .environment(TaskViewModel())
}
