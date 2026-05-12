import Foundation
import SwiftUI
import SwiftData

@Observable
final class TaskViewModel {

    var selectedTask: PomodoroTask? = nil
    var showAddTask: Bool = false
    var showEditTask: Bool = false
    var editingTask: PomodoroTask? = nil
    var filterCompleted: Bool = false

    private var modelContext: ModelContext?
    private let sync = SyncService.shared

    func setModelContext(_ ctx: ModelContext) {
        self.modelContext = ctx
        sync.setModelContext(ctx)
    }

    func addTask(
        title: String,
        notes: String = "",
        estimatedPomodoros: Int = 1,
        isToday: Bool = true
    ) {
        guard let ctx = modelContext, !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let task = PomodoroTask(
            title: title,
            notes: notes,
            estimatedPomodoros: estimatedPomodoros,
            isToday: isToday
        )
        ctx.insert(task)
        try? ctx.save()
        sync.pushTask(task)                       // ← push ke Supabase
        HapticService.shared.impact(.medium)
    }

    func delete(_ task: PomodoroTask) {
        guard let ctx = modelContext else { return }
        let id = task.id
        ctx.delete(task)
        try? ctx.save()
        sync.deleteTask(id: id)                   // ← delete di Supabase
        if selectedTask?.id == id { selectedTask = nil }
        HapticService.shared.impact(.medium)
    }

    func toggle(_ task: PomodoroTask) {
        if task.isCompleted { task.uncomplete() } else { task.complete() }
        try? modelContext?.save()
        sync.pushTask(task)                        // ← push perubahan
        HapticService.shared.impact(.light)
    }

    func update(_ task: PomodoroTask, title: String, notes: String, estimatedPomodoros: Int) {
        task.title = title
        task.notes = notes
        task.estimatedPomodoros = estimatedPomodoros
        try? modelContext?.save()
        sync.pushTask(task)
        HapticService.shared.impact(.light)
    }

    func selectForTimer(_ task: PomodoroTask?) {
        selectedTask = task
    }

    func incrementPomodoro(_ task: PomodoroTask) {
        task.completedPomodoros += 1
        try? modelContext?.save()
        sync.pushTask(task)
    }
}
