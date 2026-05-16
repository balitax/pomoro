//
//  PomodoroTask.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation
import SwiftData

@Model
final class PomodoroTask {
    var id: UUID
    var title: String
    var notes: String
    var estimatedPomodoros: Int
    var completedPomodoros: Int
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var sortOrder: Int
    var isToday: Bool

    @Relationship(deleteRule: .cascade)
    var sessions: [PomodoroSession]

    init(
        title: String,
        notes: String = "",
        estimatedPomodoros: Int = 1,
        isToday: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.estimatedPomodoros = estimatedPomodoros
        self.completedPomodoros = 0
        self.isCompleted = false
        self.createdAt = Date()
        self.completedAt = nil
        self.sortOrder = sortOrder
        self.isToday = isToday
        self.sessions = []
    }

    var progress: Double {
        guard estimatedPomodoros > 0 else { return 0 }
        return min(Double(completedPomodoros) / Double(estimatedPomodoros), 1.0)
    }

    var remainingPomodoros: Int {
        max(0, estimatedPomodoros - completedPomodoros)
    }

    func complete() {
        isCompleted = true
        completedAt = Date()
    }

    func uncomplete() {
        isCompleted = false
        completedAt = nil
    }
}
