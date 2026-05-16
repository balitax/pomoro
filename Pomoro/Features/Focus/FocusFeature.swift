//
//  FocusFeature.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import ComposableArchitecture
import SwiftUI

struct FocusFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        enum TimerState: Equatable { case idle, running, paused, completed }

        var timerState: TimerState = .idle
        var currentSession: SessionType = .focus
        var timeRemaining: TimeInterval = 0
        var totalTime: TimeInterval = 0
        var completedFocusSessions = 0
        var sessionStartDate: Date?
        var pauseStartDate: Date?
        var totalPausedDuration: TimeInterval = 0
        var currentTaskID: UUID?
        var currentTaskTitle = ""
        var isFocusModeRequested = false

        var isRunning: Bool { timerState == .running }
        var isPaused: Bool { timerState == .paused }
        var isIdle: Bool { timerState == .idle }

        var progress: Double {
            guard totalTime > 0 else { return 0 }
            return 1.0 - (timeRemaining / totalTime)
        }

        var progressForRing: Double {
            guard totalTime > 0 else { return 0 }
            return timeRemaining / totalTime
        }

        var timeDisplayString: String {
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }

        var nextSession: SessionType {
            switch currentSession {
            case .focus:
                let next = completedFocusSessions + 1
                return (next % AppSettings.shared.sessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
            case .shortBreak, .longBreak:
                return .focus
            }
        }

        var currentSessionNumber: Int {
            (completedFocusSessions % AppSettings.shared.sessionsBeforeLongBreak) + 1
        }

        var totalSessionsPerCycle: Int {
            AppSettings.shared.sessionsBeforeLongBreak
        }

        var nextSessionDurationLabel: String {
            let mins = Int(AppSettings.shared.duration(for: nextSession)) / 60
            return "\(mins) min"
        }

        var sessionDots: [Bool] {
            (0..<AppSettings.shared.sessionsBeforeLongBreak).map {
                $0 < completedFocusSessions % AppSettings.shared.sessionsBeforeLongBreak
            }
        }
    }

    enum Action {
        case startTapped
        case pauseTapped
        case resumeTapped
        case resetTapped
        case skipTapped
        case timerTick
        case sessionCompleted
        case advanceToNextSession
        case taskLinked(id: UUID?, title: String)
        case toggleFocusMode
        case focusModeDismissed
        case scenePhaseChanged(ScenePhase)
    }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.date) private var date
    @Dependency(\.soundClient) private var soundClient
    @Dependency(\.hapticClient) private var hapticClient
    @Dependency(\.notificationClient) private var notificationClient
    @Dependency(\.liveActivityClient) private var liveActivityClient

    private enum TimerCancelID { case timer }
    private enum ScenePhaseCancelID { case sceneObserver }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {

        // ── Start ──
        case .startTapped:
            guard state.timerState == .idle || state.timerState == .paused else { return .none }

            if state.timerState == .idle {
                state.timerState = .running
                state.sessionStartDate = date.now
                state.totalPausedDuration = 0
                state.totalTime = AppSettings.shared.duration(for: state.currentSession)
                state.timeRemaining = state.totalTime

                return .run { [title = state.currentTaskTitle, session = state.currentSession, duration = state.totalTime] send in
                    await soundClient.playSessionStart(session)
                    await hapticClient.impact(.medium)
                    await liveActivityClient.start(title, session, duration)
                    await notificationClient.scheduleSessionEnd(session, duration)
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: TimerCancelID.timer)
            } else {
                if let pauseStart = state.pauseStartDate {
                    state.totalPausedDuration += date.now.timeIntervalSince(pauseStart)
                    state.pauseStartDate = nil
                }
                state.syncTimeRemaining(date: date.now)
                state.timerState = .running

                let session = state.currentSession
                return .run { [remaining = state.timeRemaining, total = state.totalTime, session] send in
                    await liveActivityClient.update(remaining, total, true)
                    await notificationClient.scheduleSessionEnd(session, remaining)
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: TimerCancelID.timer)
            }

        // ── Pause ──
        case .pauseTapped:
            guard state.timerState == .running else { return .none }
            state.timerState = .paused
            state.pauseStartDate = date.now
            state.syncTimeRemaining(date: date.now)

            return .concatenate(
                .cancel(id: TimerCancelID.timer),
                .run { [remaining = state.timeRemaining, total = state.totalTime] _ in
                    await hapticClient.impact(.light)
                    await liveActivityClient.update(remaining, total, false)
                    await notificationClient.cancelPending()
                }
            )

        // ── Resume ──
        case .resumeTapped:
            guard state.timerState == .paused else { return .none }
            if let pauseStart = state.pauseStartDate {
                state.totalPausedDuration += date.now.timeIntervalSince(pauseStart)
                state.pauseStartDate = nil
            }
            state.syncTimeRemaining(date: date.now)
            state.timerState = .running
            let session = state.currentSession

            return .run { [remaining = state.timeRemaining, total = state.totalTime, session] send in
                await hapticClient.impact(.light)
                await liveActivityClient.update(remaining, total, true)
                await notificationClient.scheduleSessionEnd(session, remaining)
                for await _ in clock.timer(interval: .seconds(1)) {
                    await send(.timerTick)
                }
            }
            .cancellable(id: TimerCancelID.timer)

        // ── Timer Tick ──
        case .timerTick:
            guard state.timerState == .running else { return .none }
            state.syncTimeRemaining(date: date.now)
            let remaining = state.timeRemaining

            return .run { [remaining, total = state.totalTime] send in
                await liveActivityClient.update(max(0, ceil(remaining)), total, true)
                if remaining <= 0 {
                    await send(.sessionCompleted)
                }
            }

        // ── Session Completed ──
        case .sessionCompleted:
            state.timerState = .completed
            let session = state.currentSession
            let duration = state.totalTime
            let remaining = state.timeRemaining
            let taskID = state.currentTaskID
            let autoStart = session == .focus
                ? AppSettings.shared.autoStartBreaks
                : AppSettings.shared.autoStartFocus

            return .run { send in
                await soundClient.playSessionComplete(session)
                await hapticClient.notification(.success)
                await liveActivityClient.end()
                let actualDuration = duration - remaining
                await SyncService.shared.saveSessionLocally(
                    sessionType: session,
                    duration: duration,
                    actualDuration: actualDuration,
                    taskID: taskID
                )
                try await Task.sleep(for: .seconds(0.8))
                await send(.advanceToNextSession)
                if autoStart { await send(.startTapped) }
            }
            .cancellable(id: TimerCancelID.timer)

        // ── Advance ──
        case .advanceToNextSession:
            if state.currentSession == .focus {
                state.completedFocusSessions += 1
            }
            state.currentSession = state.nextSession
            state.timerState = .idle
            state.totalTime = AppSettings.shared.duration(for: state.currentSession)
            state.timeRemaining = state.totalTime
            state.sessionStartDate = nil
            state.pauseStartDate = nil
            state.totalPausedDuration = 0
            return .none

        // ── Reset ──
        case .resetTapped:
            state.timerState = .idle
            state.sessionStartDate = nil
            state.pauseStartDate = nil
            state.totalPausedDuration = 0
            state.totalTime = AppSettings.shared.duration(for: state.currentSession)
            state.timeRemaining = state.totalTime

            return .concatenate(
                .cancel(id: TimerCancelID.timer),
                .run { _ in
                    await hapticClient.impact(.medium)
                    await liveActivityClient.end()
                    await notificationClient.cancelPending()
                }
            )

        // ── Skip ──
        case .skipTapped:
            return .concatenate(
                .cancel(id: TimerCancelID.timer),
                .run { _ in
                    await hapticClient.impact(.medium)
                    await liveActivityClient.end()
                    await notificationClient.cancelPending()
                },
                .send(.advanceToNextSession)
            )

        // ── Task Linked ──
        case let .taskLinked(id, title):
            state.currentTaskID = id
            state.currentTaskTitle = title
            return .none

        // ── Toggle Focus Mode ──
        case .toggleFocusMode:
            state.isFocusModeRequested = true
            return .none

        case .focusModeDismissed:
            state.isFocusModeRequested = false
            return .none

        // ── Scene Phase ──
        case let .scenePhaseChanged(phase):
            switch phase {
            case .active:
                guard state.timerState == .running || state.timerState == .paused else { return .none }
                state.syncTimeRemaining(date: date.now)
                if state.timerState == .running {
                    return .run { [remaining = state.timeRemaining, total = state.totalTime] _ in
                        await liveActivityClient.update(remaining, total, true)
                    }
                }
                return .none

            case .background, .inactive:
                guard state.timerState == .running || state.timerState == .paused else { return .none }
                state.syncTimeRemaining(date: date.now)
                return .run { [remaining = state.timeRemaining, total = state.totalTime] _ in
                    await liveActivityClient.update(remaining, total, false)
                }

            @unknown default:
                return .none
            }
        }
    }
}

extension FocusFeature.State {
    mutating func syncTimeRemaining(date: Date) {
        guard let start = sessionStartDate else { return }
        let elapsed = date.timeIntervalSince(start) - totalPausedDuration
        timeRemaining = max(0, totalTime - elapsed)
    }
}
