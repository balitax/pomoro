//
//  TimerView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct TimerView: View {
    @Bindable var store: StoreOf<FocusFeature>
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(\.scenePhase) private var scenePhase
    @Environment(Language.self) private var language

    @State private var showTaskPicker = false
    @State private var showInfo = false
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ringSection
                    .offset(y: appeared ? 0 : 24)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.05), value: appeared)

                if !store.isIdle {
                    controlsRow
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                upNextCard
                    .offset(y: appeared ? 0 : 32)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.15), value: appeared)

                taskSection
                    .offset(y: appeared ? 0 : 32)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.55, dampingFraction: 0.8).delay(0.2), value: appeared)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: store.isIdle)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showInfo = true } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .onAppear { appeared = true }
        .onChange(of: taskVM.selectedTask?.id) { _, newID in
            store.send(.taskLinked(id: newID, title: taskVM.selectedTask?.title ?? ""))
        }
        .onChange(of: scenePhase) { _, phase in
            store.send(.scenePhaseChanged(phase))
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(isPresented: $showTaskPicker)
                .environment(taskVM)
        }
        .sheet(isPresented: $showInfo) { InfoView() }
    }

    private var ringSection: some View {
        VStack(spacing: 20) {
            Text(store.currentSession.displayName)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(store.currentSession.color)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(store.currentSession.color.opacity(0.1), in: Capsule())
                .animation(.easeInOut(duration: 0.3), value: store.currentSession)

            CircularTimerView(store: store)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(0..<store.totalSessionsPerCycle, id: \.self) { i in
                        Circle()
                            .fill(store.sessionDots.indices.contains(i) && store.sessionDots[i]
                                  ? store.currentSession.color : Color(.systemFill))
                            .frame(width: 8, height: 8)
                            .scaleEffect(store.sessionDots.indices.contains(i) && store.sessionDots[i] ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: store.completedFocusSessions)
                    }
                }
                HStack(spacing: 6) {
                    Text(language.timer.sessionLabel(store.currentSession.displayName))
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text(language.timer.separator).foregroundStyle(.tertiary)
                    Text(language.timer.sessionsProgress(current: store.currentSessionNumber, total: store.totalSessionsPerCycle))
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: store.currentSession)
            }
        }
    }

    private var controlsRow: some View {
        HStack {
            Spacer()
            Button { store.send(.resetTapped) } label: {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.counterclockwise").font(.system(size: 20))
                    Text(language.common.reset).font(.caption)
                }.foregroundStyle(.secondary).frame(width: 64)
            }.buttonStyle(SpringButtonStyle())
            Spacer()
            Spacer()
            Button { store.send(.skipTapped) } label: {
                VStack(spacing: 5) {
                    Image(systemName: "forward.end.fill").font(.system(size: 20))
                    Text(language.common.skip).font(.caption)
                }.foregroundStyle(.secondary).frame(width: 64)
            }.buttonStyle(SpringButtonStyle())
            Spacer()
        }.padding(.top, 4)
    }

    private var upNextCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(language.timer.upNext).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(store.nextSession.color.opacity(0.12)).frame(width: 46, height: 46)
                    Image(systemName: store.nextSession.systemImage)
                        .font(.system(size: 19)).foregroundStyle(store.nextSession.color)
                }
                .animation(.easeInOut(duration: 0.3), value: store.nextSession)
                VStack(alignment: .leading, spacing: 3) {
                    Text(store.nextSession.displayName).font(.body.weight(.medium))
                    Text(store.nextSessionDurationLabel).font(.subheadline).foregroundStyle(.secondary)
                }
                .animation(.easeInOut(duration: 0.3), value: store.nextSession)
                Spacer()
                Image(systemName: "chevron.right").font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    @ViewBuilder
    private var taskSection: some View {
        if let task = taskVM.selectedTask {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(store.currentSession.color).font(.system(size: 20))
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title).font(.subheadline.weight(.medium)).lineLimit(1)
                    Text(language.timer.taskProgress(completed: task.completedPomodoros, estimated: task.estimatedPomodoros))
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        taskVM.selectForTimer(nil)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.tertiaryLabel)).font(.system(size: 20))
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
                    Text(language.timer.linkATask)
                }
                .font(.subheadline).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity).padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain).transition(.opacity)
        }
    }
}

struct TaskPickerSheet: View {
    @Binding var isPresented: Bool
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(Language.self) private var language
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
                            Text(task.title).font(.body).foregroundStyle(.primary)
                            Text(language.timer.pomodorosRemaining(task.remainingPomodoros))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle(language.timer.chooseTask)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(language.common.cancel) { isPresented = false }
                }
            }
            .overlay {
                if tasks.isEmpty {
                    EmptyStateView(icon: "checklist", title: language.timer.noTasks, subtitle: language.timer.addTaskToLink)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TimerView(store: Store(initialState: FocusFeature.State()) { FocusFeature() })
        .environment(TaskViewModel())
}
