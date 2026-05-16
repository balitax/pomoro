//
//  MenuBarView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

#if os(macOS)
import SwiftUI
import SwiftData

// MARK: - Menu Bar Label

struct MenuBarLabel: View {
    @Environment(TimerViewModel.self) private var timerVM

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
            if timerVM.isRunning || timerVM.isPaused {
                Text(timerVM.timeDisplayString)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Menu Bar Window View

struct MenuBarView: View {
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(TaskViewModel.self) private var taskVM

    var body: some View {
        VStack(spacing: 0) {
            // Header
            menuBarHeader

            Divider()

            // Timer section
            menuBarTimer
                .padding(PDS.Spacing.md)

            Divider()

            // Quick actions
            menuBarActions
                .padding(PDS.Spacing.sm)
        }
        .frame(width: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Header

    private var menuBarHeader: some View {
        HStack {
            PomoroLogo(size: 28)
            Text("Pomoro")
                .font(.system(size: 14, weight: .semibold, design: .rounded))

            Spacer()

            SessionTypeBadge(sessionType: timerVM.currentSession, size: .compact)
        }
        .padding(.horizontal, PDS.Spacing.md)
        .padding(.vertical, PDS.Spacing.sm)
    }

    // MARK: - Timer

    private var menuBarTimer: some View {
        HStack(spacing: PDS.Spacing.lg) {
            // Mini ring
            MiniProgressRing(
                progress: timerVM.progressForRing,
                color: timerVM.currentSession.color,
                size: 48,
                lineWidth: 4
            )
            .overlay(
                Image(systemName: timerVM.currentSession.systemImage)
                    .font(.system(size: 14))
                    .foregroundStyle(timerVM.currentSession.color)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(timerVM.timeDisplayString)
                    .font(.system(size: 28, weight: .thin, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText(countsDown: true))

                Text(timerVM.currentSession.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Play/pause
            menuBarMainButton
        }
    }

    private var menuBarMainButton: some View {
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
                    .frame(width: 44, height: 44)

                Image(systemName: timerVM.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Actions

    private var menuBarActions: some View {
        VStack(spacing: 0) {
            menuBarActionButton(icon: "forward.end.fill", title: "Skip Session") {
                timerVM.skip()
            }
            menuBarActionButton(icon: "arrow.counterclockwise", title: "Reset Timer") {
                timerVM.reset()
            }
            Divider()
                .padding(.vertical, PDS.Spacing.xs)
            menuBarActionButton(icon: "arrow.up.right.square", title: "Open Pomoro") {
                NSWorkspace.shared.open(URL(string: "pomoro://")!)
            }
            menuBarActionButton(icon: "xmark.circle", title: "Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    private func menuBarActionButton(
        icon: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: PDS.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 13))
                Spacer()
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, PDS.Spacing.sm)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .hoverEffect(.highlight)
    }
}

extension View {
    @ViewBuilder
    func hoverEffect(_ effect: HoverEffect) -> some View {
        self.onHover { inside in
            if inside {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

enum HoverEffect { case highlight }
#endif
