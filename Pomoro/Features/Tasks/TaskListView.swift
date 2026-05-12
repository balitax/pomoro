import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \PomodoroTask.createdAt, order: .reverse)
    private var allTasks: [PomodoroTask]

    @State private var showAddTask = false
    @State private var showCompleted = false

    private var todayTasks: [PomodoroTask] {
        allTasks.filter { $0.isToday && !$0.isCompleted }
    }

    private var completedTasks: [PomodoroTask] {
        allTasks.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0A0B").ignoresSafeArea()

                if allTasks.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No Tasks Yet",
                        subtitle: "Add a task to track your pomodoro sessions"
                    )
                } else {
                    taskList
                }
            }
            .navigationTitle("Tasks")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar { toolbarContent }
            .sheet(isPresented: $showAddTask) {
                AddTaskSheet(isPresented: $showAddTask)
                    .environment(taskVM)
            }
        }
        .onAppear {
            taskVM.setModelContext(modelContext)
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        List {
            // Today section
            if !todayTasks.isEmpty {
                Section {
                    ForEach(todayTasks) { task in
                        TaskRowView(task: task)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation { taskVM.delete(task) }
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    taskVM.toggle(task)
                                } label: {
                                    Label("Done", systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                    }
                } header: {
                    sectionHeader("Today", count: todayTasks.count)
                }
            }

            // Completed section
            if !completedTasks.isEmpty {
                Section {
                    if showCompleted {
                        ForEach(completedTasks) { task in
                            TaskRowView(task: task)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation { taskVM.delete(task) }
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }
                                }
                        }
                    }
                } header: {
                    Button {
                        withAnimation(PDS.Animation.spring) {
                            showCompleted.toggle()
                        }
                    } label: {
                        HStack {
                            sectionHeader("Completed", count: completedTasks.count)
                            Spacer()
                            Image(systemName: showCompleted ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text("\(count)")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.3), in: Capsule())
        }
        .textCase(nil)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showAddTask = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(PDS.Colors.focusRed)
            }
        }
    }
}
