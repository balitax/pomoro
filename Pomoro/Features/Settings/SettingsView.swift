//
//  SettingsView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(TimerViewModel.self) private var timerVM

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0B").ignoresSafeArea()

            List {
                // Timer durations
                timerSection

                // Behavior
                behaviorSection

                // Sound & Haptics
                soundSection

                // Appearance
                appearanceSection

                // Notifications
                notificationsSection

                // About
                aboutSection
            }
            .scrollContentBackground(.hidden)
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    // MARK: - Timer Section

    private let focusPresets: [Double] = [5, 10, 15, 25, 30, 45, 60]

    private var timerSection: some View {
        Section {
            focusPresetRow
            durationRow("Short Break", value: $settings.shortBreakDuration, range: 1...30, suffix: "min")
            durationRow("Long Break", value: $settings.longBreakDuration, range: 5...60, suffix: "min")

            HStack {
                Label("Sessions Before Long Break", systemImage: "repeat.circle")
                Spacer()
                Stepper("\(settings.sessionsBeforeLongBreak)", value: $settings.sessionsBeforeLongBreak, in: 2...8)
                    .labelsHidden()
                Text("\(settings.sessionsBeforeLongBreak)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(PDS.Colors.focusRed)
                    .frame(width: 24)
            }

            HStack {
                Label("Daily Goal", systemImage: "target")
                Spacer()
                Stepper("\(settings.dailyGoal)", value: $settings.dailyGoal, in: 1...20)
                    .labelsHidden()
                Text("\(settings.dailyGoal)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(PDS.Colors.focusRed)
                    .frame(width: 28)
            }
        } header: {
            Label("Timer", systemImage: "timer")
        }
    }

    // MARK: - Behavior Section

    private var behaviorSection: some View {
        Section {
            Toggle(isOn: $settings.autoStartBreaks) {
                Label("Auto-start Breaks", systemImage: "play.circle")
            }
            Toggle(isOn: $settings.autoStartFocus) {
                Label("Auto-start Focus", systemImage: "arrow.clockwise.circle")
            }
        } header: {
            Label("Behavior", systemImage: "gearshape")
        }
    }

    // MARK: - Sound Section

    private var soundSection: some View {
        Section {
            Toggle(isOn: $settings.soundEnabled) {
                Label("Session Sounds", systemImage: "speaker.wave.2.fill")
            }
            Toggle(isOn: $settings.tickingEnabled) {
                Label("Ticking Sound", systemImage: "clock")
            }
            #if os(iOS)
            Toggle(isOn: $settings.hapticEnabled) {
                Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
            }
            #endif

            // Ambient sound picker
            Picker(selection: $settings.selectedAmbient) {
                ForEach(AmbientSound.allCases) { sound in
                    Label(sound.displayName, systemImage: sound.systemImage)
                        .tag(sound.rawValue)
                }
            } label: {
                Label("Ambient Sound", systemImage: "waveform")
            }
        } header: {
            Label("Sound & Haptics", systemImage: "speaker.wave.2")
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            Picker(selection: $settings.colorSchemeRaw) {
                Text("System").tag(0)
                Text("Light").tag(1)
                Text("Dark").tag(2)
            } label: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $settings.showMotivation) {
                Label("Motivational Messages", systemImage: "quote.bubble.fill")
            }
        } header: {
            Label("Appearance", systemImage: "paintpalette")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $settings.notifyOnComplete) {
                Label("Session Complete", systemImage: "bell.fill")
            }
            Toggle(isOn: $settings.notifyBreak) {
                Label("Break Reminders", systemImage: "bell.badge")
            }
        } header: {
            Label("Notifications", systemImage: "bell")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://example.com/pomoro/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }

            Link(destination: URL(string: "https://example.com/pomoro/support")!) {
                Label("Support", systemImage: "questionmark.circle.fill")
            }
        } header: {
            Label("About", systemImage: "app.badge")
        }
    }

    // MARK: - Focus Preset Row

    private var focusPresetRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus Duration")
                .font(.body)

            HStack(spacing: 8) {
                ForEach(focusPresets, id: \.self) { preset in
                    Button {
                        settings.focusDuration = preset
                    } label: {
                        Text("\(Int(preset)) min")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(settings.focusDuration == preset ? .white : PDS.Colors.focusRed)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                settings.focusDuration == preset
                    ? PDS.Colors.focusRed
                    : PDS.Colors.focusRed.opacity(0.1)
            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Duration Row

    private func durationRow(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        suffix: String
    ) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(Int(value.wrappedValue)) \(suffix)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(PDS.Colors.focusRed)
                .frame(minWidth: 60, alignment: .trailing)
            Stepper("", value: value, in: range, step: 1)
                .labelsHidden()
                .frame(width: 80)
        }
    }
}
