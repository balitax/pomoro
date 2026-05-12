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

    var nextSessionLabel: String {
        nextSession.displayName
    }

    private var nextSession: SessionType {
        switch currentSession {
        case .focus:
            let next = completedFocusSessions + 1
            return (next % settings.sessionsBeforeLongBreak == 0) ? .longBreak : .shortBreak
        case .shortBreak, .longBreak:
            return .focus
        }
    }

    // MARK: - Session info chips

    var sessionDots: [Bool] {
        (0..<settings.sessionsBeforeLongBreak).map { $0 < completedFocusSessions % settings.sessionsBeforeLongBreak }
    }

    // MARK: - Private

    private var timer: AnyCancellable?
    private var sessionStartDate: Date?
    private var modelContext: ModelContext?
    private let settings = AppSettings.shared
    private let notifications = NotificationService.shared
    private let haptics = HapticService.shared
    private let sounds = SoundService.shared

    // MARK: - Init

    init() {
        resetToCurrentSession()
    }

    func setModelContext(_ ctx: ModelContext) {
        self.modelContext = ctx
    }

    // MARK: - Controls

    func start() {
        guard timerState == .idle || timerState == .paused else { return }
        if timerState == .idle {
            sessionStartDate = Date()
            sounds.playSessionStart(session: currentSession)
            haptics.impact(.medium)
        }
        timerState = .running
        scheduleNotification()
        startTicking()
    }

    func pause() {
        guard timerState == .running else { return }
        timerState = .paused
        stopTicking()
        cancelNotification()
        haptics.impact(.light)
    }

    func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        scheduleNotification()
        startTicking()
        haptics.impact(.light)
    }

    func skip() {
        stopTicking()
        cancelNotification()
        haptics.impact(.medium)
        advanceToNextSession()
    }

    func reset() {
        stopTicking()
        cancelNotification()
        timerState = .idle
        resetToCurrentSession()
        haptics.impact(.medium)
    }

    func toggleFocusMode() {
        isFocusModeRequested = true
    }

    // MARK: - Private Helpers

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
        guard timerState == .running else { return }
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
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
