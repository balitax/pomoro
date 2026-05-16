//
//  TimerView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(TaskViewModel.self)  private var taskVM
    @Environment(\.modelContext)      private var modelContext

    @State private var showTaskPicker = false
    @State private var showInfo       = false
    @State private var appeared       = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Ring section
                ringSection
                    .offset(y: appeared ? 0 : 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: appeared)

                // Controls — slide up when active
                if !timerVM.isIdle {
                    controlsRow
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Up Next
                upNextCard
                    .offset(y: appeared ? 0 : 32)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.15), value: appeared)

                // Task
                taskSection
                    .offset(y: appeared ? 0 : 32)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.2), value: appeared)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: timerVM.isIdle)
        }
        .background(Color(.systemGroupedBackground))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .onAppear {
            timerVM.setModelContext(modelContext)
            appeared = true
        }
        .onChange(of: taskVM.selectedTask?.id) { _, newID in
            timerVM.currentTaskID = newID
            timerVM.currentTaskTitle = taskVM.selectedTask?.title ?? ""
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(isPresented: $showTaskPicker)
                .environment(taskVM)
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
    }

    // MARK: - Ring Section

    private var ringSection: some View {
        VStack(spacing: 20) {
            // Session badge
            Text(timerVM.currentSession.displayName)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(timerVM.currentSession.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(timerVM.currentSession.color.opacity(0.1),
                            in: Capsule())
                .animation(.easeInOut(duration: 0.3), value: timerVM.currentSession)

            // Ring
            CircularTimerView()

            // Dots + session info
            VStack(spacing: 8) {
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<timerVM.totalSessionsPerCycle, id: \.self) { i in
                        Circle()
                            .fill(timerVM.sessionDots.indices.contains(i) && timerVM.sessionDots[i]
                                  ? timerVM.currentSession.color
                                  : Color(.systemFill))
                            .frame(width: 8, height: 8)
                            .scaleEffect(timerVM.sessionDots.indices.contains(i) && timerVM.sessionDots[i] ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: timerVM.completedFocusSessions)
                    }
                }

                // Session label
                HStack(spacing: 6) {
                    Text("\(timerVM.currentSession.displayName) session")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text("\(timerVM.currentSessionNumber) of \(timerVM.totalSessionsPerCycle)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: timerVM.currentSession)
            }
        }
    }

    // MARK: - Controls Row (reset + skip)

    private var controlsRow: some View {
        HStack {
            Spacer()

            Button {
                timerVM.reset()
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20, weight: .regular))
                    Text("Reset")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .frame(width: 64)
            }
            .buttonStyle(SpringButtonStyle())

            Spacer()
            Spacer()

            Button {
                timerVM.skip()
            } label: {
                VStack(spacing: 5) {
                    Image(systemName: "forward.end.fill")
                        .font(.system(size: 20, weight: .regular))
                    Text("Skip")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                .frame(width: 64)
            }
            .buttonStyle(SpringButtonStyle())

            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Up Next Card

    private var upNextCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Up Next")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(timerVM.nextSession.color.opacity(0.12))
                        .frame(width: 46, height: 46)
                    Image(systemName: timerVM.nextSession.systemImage)
                        .font(.system(size: 19))
                        .foregroundStyle(timerVM.nextSession.color)
                }
                .animation(.easeInOut(duration: 0.3), value: timerVM.nextSession)

                VStack(alignment: .leading, spacing: 3) {
                    Text(timerVM.nextSession.displayName)
                        .font(.body.weight(.medium))
                    Text(timerVM.nextSessionDurationLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: timerVM.nextSession)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Task Section

    @ViewBuilder
    private var taskSection: some View {
        if let task = taskVM.selectedTask {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(timerVM.currentSession.color)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Text("\(task.completedPomodoros) / \(task.estimatedPomodoros) sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        taskVM.selectForTimer(nil)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.tertiaryLabel))
                        .font(.system(size: 20))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .transition(.scale(scale: 0.95).combined(with: .opacity))
        } else {
            Button {
                showTaskPicker = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                    Text("Link a task")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .transition(.opacity)
        }
    }
}

// MARK: - Task Picker Sheet

struct TaskPickerSheet: View {
    @Binding var isPresented: Bool
    @Environment(TaskViewModel.self) private var taskVM
    @Query(filter: #Predicate<PomodoroTask> { !$0.isCompleted },
           sort: \PomodoroTask.createdAt, order: .reverse)
    private var tasks: [PomodoroTask]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                Button {
                    taskVM.selectForTimer(task)
                    isPresented = false
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(task.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("\(task.remainingPomodoros) pomodoros remaining")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Choose Task")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .overlay {
                if tasks.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No Tasks",
                        subtitle: "Add a task to link it to your session"
                    )
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }
}

#Preview {
    TimerView()
        .environment(TimerViewModel())
        .environment(TaskViewModel())
}
