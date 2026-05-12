import SwiftUI

struct CircularTimerView: View {
    @Environment(TimerViewModel.self) private var timerVM

    @State private var isAnimating = false

    private let ringSize: CGFloat = PDS.Ring.size
    private let lineWidth: CGFloat = PDS.Ring.lineWidth

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    timerVM.currentSession.color.opacity(PDS.Ring.backgroundOpacity),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)

            // Progress ring
            Circle()
                .trim(from: 0, to: timerVM.progressForRing)
                .stroke(
                    AngularGradient(
                        colors: timerVM.currentSession.gradientColors,
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .animation(
                    timerVM.isRunning ? PDS.Animation.timerRing : PDS.Animation.spring,
                    value: timerVM.progressForRing
                )

            // Glow effect on ring tip
            if timerVM.isRunning || timerVM.isPaused {
                ringTipGlow
            }

            // Center content
            centerContent
        }
        .frame(width: ringSize, height: ringSize)
    }

    // MARK: - Ring Tip Glow

    private var ringTipGlow: some View {
        let angle = (timerVM.progressForRing * 360 - 90) * .pi / 180
        let radius = ringSize / 2
        let x = cos(angle) * radius
        let y = sin(angle) * radius

        return Circle()
            .fill(timerVM.currentSession.color)
            .frame(width: lineWidth * 1.5, height: lineWidth * 1.5)
            .blur(radius: 4)
            .offset(x: x, y: y)
            .opacity(timerVM.isRunning ? 1 : 0.5)
            .animation(PDS.Animation.timerRing, value: timerVM.progressForRing)
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: 8) {
            // Timer display
            Text(timerVM.timeDisplayString)
                .font(.system(size: 64, weight: .thin, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.primary)
                .contentTransition(.numericText(countsDown: true))
                .animation(PDS.Animation.fast, value: timerVM.timeDisplayString)

            // State label
            stateLabel
        }
    }

    @ViewBuilder
    private var stateLabel: some View {
        switch timerVM.timerState {
        case .idle:
            Text("Tap to start")
                .font(PDS.Typography.caption)
                .foregroundStyle(.tertiary)
                .transition(.opacity)
        case .running:
            HStack(spacing: 4) {
                Circle()
                    .fill(timerVM.currentSession.color)
                    .frame(width: 6, height: 6)
                    .scaleEffect(isAnimating ? 1.3 : 0.7)
                    .animation(.easeInOut(duration: 0.8).repeatForever(), value: isAnimating)
                Text(timerVM.currentSession.displayName)
                    .font(PDS.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .onAppear { isAnimating = true }
            .onDisappear { isAnimating = false }
        case .paused:
            Text("Paused")
                .font(PDS.Typography.caption)
                .foregroundStyle(.secondary)
                .transition(.opacity)
        case .completed:
            Text("Done!")
                .font(PDS.Typography.caption)
                .foregroundStyle(timerVM.currentSession.color)
                .transition(.scale.combined(with: .opacity))
        }
    }
}
