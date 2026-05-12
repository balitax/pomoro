import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(\.modelContext) private var modelContext

    @State private var animateRing = false
    @State private var showTaskPicker = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Ambient background
            sessionBackground
                .ignoresSafeArea()
                .animation(PDS.Animation.smooth, value: timerVM.currentSession)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)

                    // Session type header
                    sessionHeader
                        .padding(.bottom, PDS.Spacing.lg)

                    // Main timer ring
                    CircularTimerView()
                        .padding(.bottom, PDS.Spacing.lg)

                    // Session dots (progress through pomodoro cycle)
                    sessionDotsView
                        .padding(.bottom, PDS.Spacing.xl)

                    // Controls
                    SessionControlsView()
                        .padding(.horizontal, PDS.Spacing.lg)
                        .padding(.bottom, PDS.Spacing.lg)

                    // Active task card
                    if let task = taskVM.selectedTask {
                        activeTaskCard(task)
                            .padding(.horizontal, PDS.Spacing.lg)
                            .padding(.bottom, PDS.Spacing.md)
                    } else {
                        pickTaskButton
                            .padding(.horizontal, PDS.Spacing.lg)
                            .padding(.bottom, PDS.Spacing.md)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .onAppear {
            timerVM.setModelContext(modelContext)
        }
        .sheet(isPresented: $showTaskPicker) {
            TaskPickerSheet(isPresented: $showTaskPicker)
                .environment(taskVM)
        }
    }

    // MARK: - Background

    private var sessionBackground: some View {
        ZStack {
            Color(hex: "#0A0A0B")

            // Radial glow based on session
            RadialGradient(
                colors: [
                    timerVM.currentSession.color.opacity(timerVM.isRunning ? 0.18 : 0.08),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .scaleEffect(pulseScale)
            .animation(
                timerVM.isRunning
                    ? .easeInOut(duration: 2).repeatForever(autoreverses: true)
                    : .easeInOut(duration: 0.5),
                value: pulseScale
            )
        }
        .onChange(of: timerVM.isRunning) { _, running in
            pulseScale = running ? 1.15 : 1.0
        }
    }

    // MARK: - Session Header

    private var sessionHeader: some View {
        VStack(spacing: PDS.Spacing.xs) {
            Text(timerVM.currentSession.shortName)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(2)
                .foregroundStyle(timerVM.currentSession.color)

            if !timerVM.isRunning && !timerVM.isPaused {
                Text("Next: \(timerVM.nextSessionLabel)")
                    .font(PDS.Typography.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(PDS.Animation.smooth, value: timerVM.isRunning)
    }

    // MARK: - Session Dots

    private var sessionDotsView: some View {
        HStack(spacing: 6) {
            ForEach(Array(timerVM.sessionDots.enumerated()), id: \.offset) { _, completed in
                Circle()
                    .fill(completed ? timerVM.currentSession.color : timerVM.currentSession.color.opacity(0.2))
                    .frame(width: 7, height: 7)
                    .animation(PDS.Animation.spring, value: completed)
            }
        }
    }

    // MARK: - Active Task Card

    private func activeTaskCard(_ task: PomodoroTask) -> some View {
        HStack(spacing: PDS.Spacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(timerVM.currentSession.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(PDS.Typography.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundStyle(.primary)

                Text("\(task.completedPomodoros)/\(task.estimatedPomodoros) pomodoros")
                    .font(PDS.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                taskVM.selectForTimer(nil)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 18))
            }
        }
        .padding(PDS.Spacing.md)
        .glassBackground(cornerRadius: PDS.Radius.medium)
        .transition(.scale.combined(with: .opacity))
        .animation(PDS.Animation.spring, value: task.id)
    }

    // MARK: - Pick Task Button

    private var pickTaskButton: some View {
        Button {
            showTaskPicker = true
        } label: {
            HStack(spacing: PDS.Spacing.sm) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 16))
                Text("Link a task")
                    .font(PDS.Typography.callout)
            }
            .foregroundStyle(.secondary)
            .padding(PDS.Spacing.md)
            .frame(maxWidth: .infinity)
            .glassBackground(cornerRadius: PDS.Radius.medium)
        }
        .buttonStyle(.plain)
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
                                .font(PDS.Typography.body)
                                .foregroundStyle(.primary)
                            Text("\(task.remainingPomodoros) pomodoros remaining")
                                .font(PDS.Typography.caption)
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
            .navigationBarTitleDisplayMode(.inline)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
