import Foundation
import SwiftData

@Model
final class PomodoroSession {
    var id: UUID
    var sessionType: String      // SessionType.rawValue
    var duration: TimeInterval   // planned duration in seconds
    var actualDuration: TimeInterval  // how long actually ran
    var startedAt: Date
    var completedAt: Date?
    var wasCompleted: Bool

    // Relationship back to task (optional — free sessions allowed)
    var task: PomodoroTask?

    init(
        sessionType: SessionType,
        duration: TimeInterval,
        task: PomodoroTask? = nil
    ) {
        self.id = UUID()
        self.sessionType = sessionType.rawValue
        self.duration = duration
        self.actualDuration = 0
        self.startedAt = Date()
        self.completedAt = nil
        self.wasCompleted = false
        self.task = task
    }

    var type: SessionType {
        SessionType(rawValue: sessionType) ?? .focus
    }

    func complete(actualDuration: TimeInterval) {
        self.wasCompleted = true
        self.actualDuration = actualDuration
        self.completedAt = Date()
        if type == .focus {
            task?.completedPomodoros += 1
        }
    }

    var dayString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: startedAt)
    }
}
