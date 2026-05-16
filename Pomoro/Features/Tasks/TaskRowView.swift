//
//  TaskRowView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

struct TaskRowView: View {
    let task: PomodoroTask
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(TimerViewModel.self) private var timerVM

    @State private var isPressed = false

    var isSelected: Bool {
        taskVM.selectedTask?.id == task.id
    }

    var body: some View {
        HStack(spacing: PDS.Spacing.md) {
            // Completion toggle
            completionButton

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(PDS.Typography.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(PDS.Typography.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Pomodoro progress
                pomodoroProgress
            }

            Spacer()

            // Select for timer
            if !task.isCompleted {
                selectButton
            }
        }
        .padding(.horizontal, PDS.Spacing.md)
        .padding(.vertical, PDS.Spacing.md)
        .background(rowBackground)
        .clipShape(RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous))
    }

    // MARK: - Completion Button

    private var completionButton: some View {
        Button {
            taskVM.toggle(task)
        } label: {
            ZStack {
                Circle()
                    .strokeBorder(
                        task.isCompleted ? Color.green : Color.secondary.opacity(0.3),
                        lineWidth: 1.5
                    )
                    .frame(width: 24, height: 24)

                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.green)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pomodoro Progress

    private var pomodoroProgress: some View {
        HStack(spacing: 4) {
            ForEach(0..<task.estimatedPomodoros, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(i < task.completedPomodoros
                          ? PDS.Colors.focusRed
                          : Color.secondary.opacity(0.2))
                    .frame(width: 12, height: 5)
                    .animation(PDS.Animation.spring, value: task.completedPomodoros)
            }

            Text("\(task.completedPomodoros)/\(task.estimatedPomodoros)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.tertiary)
                .padding(.leading, 2)
        }
    }

    // MARK: - Select Button

    private var selectButton: some View {
        Button {
            withAnimation(PDS.Animation.spring) {
                taskVM.selectForTimer(isSelected ? nil : task)
            }
        } label: {
            Image(systemName: isSelected ? "timer.circle.fill" : "timer.circle")
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? PDS.Colors.focusRed : Color.secondary.opacity(0.4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Background

    private var rowBackground: some View {
        Group {
            if isSelected {
                RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous)
                    .fill(PDS.Colors.focusRed.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous)
                            .strokeBorder(PDS.Colors.focusRed.opacity(0.2), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: PDS.Radius.medium, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 0.5)
                    )
            }
        }
    }
}
