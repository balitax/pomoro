//
//  AddTaskSheet.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    @Environment(TaskViewModel.self) private var taskVM

    @State private var title = ""
    @State private var notes = ""
    @State private var estimatedPomodoros = 1
    @State private var isToday = true
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task name", text: $title, axis: .vertical)
                        .font(PDS.Typography.body)
                        .focused($titleFocused)
                        .lineLimit(1...3)

                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .font(PDS.Typography.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1...5)
                }

                Section("Pomodoros") {
                    HStack {
                        Text("Estimated sessions")
                        Spacer()
                        Stepper("\(estimatedPomodoros)", value: $estimatedPomodoros, in: 1...12)
                            .labelsHidden()
                        Text("\(estimatedPomodoros)")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(PDS.Colors.focusRed)
                            .frame(width: 28)
                    }

                    // Visual pomodoro selector
                    pomoDotsSelector
                }

                Section {
                    Toggle("Add to today", isOn: $isToday)
                }
            }
            .navigationTitle("New Task")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        taskVM.addTask(
                            title: title,
                            notes: notes,
                            estimatedPomodoros: estimatedPomodoros,
                            isToday: isToday
                        )
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        #endif
        .onAppear { titleFocused = true }
    }

    // MARK: - Pomo Dots Selector

    private var pomoDotsSelector: some View {
        VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...12, id: \.self) { n in
                        Button {
                            withAnimation(PDS.Animation.spring) {
                                estimatedPomodoros = n
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(n <= estimatedPomodoros
                                          ? PDS.Colors.focusRed
                                          : Color.secondary.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Text("\(n)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(n <= estimatedPomodoros ? .white : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
