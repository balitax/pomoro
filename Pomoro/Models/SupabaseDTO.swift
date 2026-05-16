//
//  SupabaseDTO.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation

// MARK: - Task DTO

/// Representasi flat PomodoroTask untuk Supabase PostgreSQL
struct TaskDTO: Codable, Identifiable, Sendable {
    let id: UUID
    let userID: UUID
    var title: String
    var notes: String
    var estimatedPomodoros: Int
    var completedPomodoros: Int
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var sortOrder: Int
    var isToday: Bool
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID              = "user_id"
        case title
        case notes
        case estimatedPomodoros  = "estimated_pomodoros"
        case completedPomodoros  = "completed_pomodoros"
        case isCompleted         = "is_completed"
        case createdAt           = "created_at"
        case completedAt         = "completed_at"
        case sortOrder           = "sort_order"
        case isToday             = "is_today"
        case updatedAt           = "updated_at"
    }

    /// Buat DTO dari SwiftData model
    init(from task: PomodoroTask, userID: UUID) {
        self.id                  = task.id
        self.userID              = userID
        self.title               = task.title
        self.notes               = task.notes
        self.estimatedPomodoros  = task.estimatedPomodoros
        self.completedPomodoros  = task.completedPomodoros
        self.isCompleted         = task.isCompleted
        self.createdAt           = task.createdAt
        self.completedAt         = task.completedAt
        self.sortOrder           = task.sortOrder
        self.isToday             = task.isToday
        self.updatedAt           = Date()
    }

    /// Apply DTO ke SwiftData model (update fields)
    func apply(to task: PomodoroTask) {
        task.title               = title
        task.notes               = notes
        task.estimatedPomodoros  = estimatedPomodoros
        task.completedPomodoros  = completedPomodoros
        task.isCompleted         = isCompleted
        task.completedAt         = completedAt
        task.sortOrder           = sortOrder
        task.isToday             = isToday
    }
}

// MARK: - Session DTO

/// Representasi flat PomodoroSession untuk Supabase PostgreSQL
struct SessionDTO: Codable, Identifiable, Sendable {
    let id: UUID
    let userID: UUID
    var taskID: UUID?
    var sessionType: String
    var duration: Double
    var actualDuration: Double
    var startedAt: Date
    var completedAt: Date?
    var wasCompleted: Bool
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID          = "user_id"
        case taskID          = "task_id"
        case sessionType     = "session_type"
        case duration
        case actualDuration  = "actual_duration"
        case startedAt       = "started_at"
        case completedAt     = "completed_at"
        case wasCompleted    = "was_completed"
        case updatedAt       = "updated_at"
    }

    init(from session: PomodoroSession, userID: UUID) {
        self.id             = session.id
        self.userID         = userID
        self.taskID         = session.task?.id
        self.sessionType    = session.sessionType
        self.duration       = session.duration
        self.actualDuration = session.actualDuration
        self.startedAt      = session.startedAt
        self.completedAt    = session.completedAt
        self.wasCompleted   = session.wasCompleted
        self.updatedAt      = Date()
    }
}
