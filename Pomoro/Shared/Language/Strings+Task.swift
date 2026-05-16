//
//  Strings+Task.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Tasks

struct TaskStrings: StringsBase {
    let language: LanguageOption

    var title: String { localized("Tasks", "Tugas") }
    var noTasksYet: String { localized("No Tasks Yet", "Belum Ada Tugas") }
    var noTasksDescription: String { localized("Add a task to track your pomodoro sessions", "Tambahkan tugas untuk melacak sesi pomodoro Anda") }
    var today: String { localized("Today", "Hari Ini") }
    var completed: String { localized("Completed", "Selesai") }
    var taskName: String { localized("Task name", "Nama tugas") }
    var notes: String { localized("Notes (optional)", "Catatan (opsional)") }
    var pomodoros: String { localized("Pomodoros", "Pomodoro") }
    var estimatedSessions: String { localized("Estimated sessions", "Perkiraan sesi") }
    var addToToday: String { localized("Add to today", "Tambahkan ke hari ini") }
    var newTask: String { localized("New Task", "Tugas Baru") }

    func progressLabel(completed: Int, estimated: Int) -> String {
        "\(completed)/\(estimated)"
    }
}
