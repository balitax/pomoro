//
//  TaskListView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(\.modelContext) private var modelContext
    @Environment(Language.self) private var language

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
                        title: language.tasks.noTasksYet,
                        subtitle: language.tasks.noTasksDescription
                    )
                } else {
                    taskList
                }
            }
            .navigationTitle(language.tasks.title)
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

    private var taskList: some View {
        List {
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
                                    Label(language.common.delete, systemImage: "trash.fill")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    taskVM.toggle(task)
                                } label: {
                                    Label(language.common.done, systemImage: "checkmark.circle.fill")
                                }
                                .tint(.green)
                            }
                    }
                } header: {
                    sectionHeader(language.tasks.today, count: todayTasks.count)
                }
            }

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
                                        Label(language.common.delete, systemImage: "trash.fill")
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
                            sectionHeader(language.tasks.completed, count: completedTasks.count)
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
