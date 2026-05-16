//
//  TimerViewModel.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation
import SwiftUI
import Combine
import SwiftData

@Observable
final class TimerViewModel {

    // MARK: - State

    enum TimerState: Equatable {
        case idle
        case running
        case paused
        case completed
    }

    var currentSession: SessionType = .focus
    var timerState: TimerState = .idle
    var timeRemaining: TimeInterval = 0
    var totalTime: TimeInterval = 0
    var completedFocusSessions: Int = 0
    var currentTaskID: UUID? = nil
    var currentTaskTitle: String = ""
    var isFocusModeRequested: Bool = false

    // MARK: - Computed

    var isRunning: Bool { timerState == .running }
    var isPaused:  Bool { timerState == .paused  }
    var isIdle:    Bool { timerState == .idle     }

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

    var nextSessionLabel: String { nextSession.displayName }

    var nextSession: SessionType {
        switch currentSession {
        case .focus:
            let next = completedFocusSessions + 1
            return (next % settings.sessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            return .focus
        }
    }

    var currentSessionNumber: Int {
        (completedFocusSessions % settings.sessionsBeforeLongBreak) + 1
    }

    var totalSessionsPerCycle: Int {
        settings.sessionsBeforeLongBreak
    }

    var nextSessionDurationLabel: String {
        let mins = Int(settings.duration(for: nextSession)) / 60
        return "\(mins) min"
    }

    // MARK: - Session info chips

    var sessionDots: [Bool] {
        (0..<settings.sessionsBeforeLongBreak).map { $0 < completedFocusSessions % settings.sessionsBeforeLongBreak }
    }

    // MARK: - Private

    private var timer: AnyCancellable?
    private var sessionStartDate: Date?
    private var pauseStartDate: Date?
    private var totalPausedDuration: TimeInterval = 0
    private var modelContext: ModelContext?
    private let settings = AppSettings.shared
    private let notifications = NotificationService.shared
    private let haptics = HapticService.shared
    private let sounds = SoundService.shared
    #if os(iOS)
    private let liveActivity = LiveActivityManager.shared
    #endif

    // MARK: - Init

    init() {
        resetToCurrentSession()
        #if os(iOS)
        setupLiveActivityBackgroundHandling()
        #endif
    }

    #if os(iOS)
    private func setupLiveActivityBackgroundHandling() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppResigningActive()
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppBecameActive()
        }
    }

    private func handleAppBecameActive() {
        guard timerState == .running || timerState == .paused else { return }
        syncTimeRemaining()
        if timerState == .running {
            liveActivity.update(
                timeRemaining: timeRemaining,
                totalTime: totalTime,
                isRunning: true
            )
        }
    }

    private func handleAppResigningActive() {
        guard timerState == .running || timerState == .paused else { return }
        syncTimeRemaining()
        liveActivity.update(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            isRunning: false
        )
    }
    #endif

    func setModelContext(_ ctx: ModelContext) {
        self.modelContext = ctx
    }

    // MARK: - Controls

    func start() {
        guard timerState == .idle || timerState == .paused else { return }
        if timerState == .idle {
            sessionStartDate = Date()
            totalPausedDuration = 0
            sounds.playSessionStart(session: currentSession)
            haptics.impact(.medium)
            #if os(iOS)
            liveActivity.start(
                taskTitle: currentTaskTitle,
                session: currentSession,
                duration: totalTime
            )
            #endif
        } else {
            if let pauseStart = pauseStartDate {
                totalPausedDuration += Date().timeIntervalSince(pauseStart)
                pauseStartDate = nil
            }
            syncTimeRemaining()
            #if os(iOS)
            liveActivity.update(
                timeRemaining: timeRemaining,
                totalTime: totalTime,
                isRunning: true
            )
            #endif
        }
        timerState = .running
        scheduleNotification()
        startTicking()
    }

    func pause() {
        guard timerState == .running else { return }
        timerState = .paused
        pauseStartDate = Date()
        stopTicking()
        cancelNotification()
        haptics.impact(.light)
        syncTimeRemaining()
        #if os(iOS)
        liveActivity.update(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            isRunning: false
        )
        #endif
    }

    func resume() {
        guard timerState == .paused else { return }
        if let pauseStart = pauseStartDate {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartDate = nil
        }
        timerState = .running
        scheduleNotification()
        startTicking()
        haptics.impact(.light)
        syncTimeRemaining()
        #if os(iOS)
        liveActivity.update(
            timeRemaining: timeRemaining,
            totalTime: totalTime,
            isRunning: true
        )
        #endif
    }

    func skip() {
        stopTicking()
        cancelNotification()
        haptics.impact(.medium)
        #if os(iOS)
        liveActivity.end()
        #endif
        advanceToNextSession()
    }

    func reset() {
        stopTicking()
        cancelNotification()
        timerState = .idle
        resetToCurrentSession()
        haptics.impact(.medium)
        #if os(iOS)
        liveActivity.end()
        #endif
    }

    func toggleFocusMode() {
        isFocusModeRequested = true
    }

    // MARK: - Private Helpers

    private func syncTimeRemaining() {
        guard let start = sessionStartDate else { return }
        let elapsed = Date().timeIntervalSince(start) - totalPausedDuration
        timeRemaining = max(0, totalTime - elapsed)
    }

    private func startTicking() {
        stopTicking()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func stopTicking() {
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        guard timerState == .running, let start = sessionStartDate else { return }
        let elapsed = Date().timeIntervalSince(start) - totalPausedDuration
        let remaining = max(0, totalTime - elapsed)

        timeRemaining = remaining

        #if os(iOS)
        liveActivity.update(
            timeRemaining: max(0, ceil(remaining)),
            totalTime: totalTime,
            isRunning: true
        )
        #endif

        if remaining <= 0 {
            sessionCompleted()
        }
    }

    private func sessionCompleted() {
        stopTicking()
        timerState = .completed
        sounds.playSessionComplete(session: currentSession)
        haptics.notification(.success)
        saveSession()

        if currentSession == .focus {
            completedFocusSessions += 1
        }

        #if os(iOS)
        liveActivity.end()
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let autoStart = currentSession.isBreak ? settings.autoStartFocus : settings.autoStartBreaks
            advanceToNextSession()
            if autoStart { start() }
        }
    }

    private func advanceToNextSession() {
        let next = nextSession
        currentSession = next
        timerState = .idle
        resetToCurrentSession()
    }

    private func resetToCurrentSession() {
        totalTime = settings.duration(for: currentSession)
        timeRemaining = totalTime
    }

    private func saveSession() {
        guard let ctx = modelContext else { return }
        let elapsed = (totalTime - timeRemaining)
        let session = PomodoroSession(
            sessionType: currentSession,
            duration: totalTime,
            task: currentTaskID.flatMap { id in
                try? ctx.fetch(
                    FetchDescriptor<PomodoroTask>(
                        predicate: #Predicate { $0.id == id }
                    )
                ).first
            }
        )
        session.complete(actualDuration: elapsed)
        ctx.insert(session)
        try? ctx.save()
        SyncService.shared.pushSession(session)   // ← push ke Supabase
    }

    private func scheduleNotification() {
        guard settings.notifyOnComplete else { return }
        notifications.scheduleSessionEnd(
            sessionType: currentSession,
            timeRemaining: timeRemaining
        )
    }

    private func cancelNotification() {
        notifications.cancelPending()
    }
}
