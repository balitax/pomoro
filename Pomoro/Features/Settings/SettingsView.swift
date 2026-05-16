//
//  SettingsView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(Language.self) private var language

    var body: some View {
        ZStack {
            Color(hex: "#0A0A0B").ignoresSafeArea()

            List {
                timerSection
                behaviorSection
                languageSection
                soundSection
                appearanceSection
                notificationsSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
        }
        .navigationTitle(language.settings.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private let focusPresets: [Double] = [5, 10, 15, 25, 30, 45, 60]

    @ViewBuilder
    private var timerSection: some View {
        Section {
            focusPresetRow
            durationRow(language.settings.shortBreak, value: $settings.shortBreakDuration, range: 1...30)
            durationRow(language.settings.longBreak, value: $settings.longBreakDuration, range: 5...60)

            HStack {
                Label(language.settings.sessionsBeforeLongBreak, systemImage: "repeat.circle")
                Spacer()
                Stepper("\(settings.sessionsBeforeLongBreak)", value: $settings.sessionsBeforeLongBreak, in: 2...8)
                    .labelsHidden()
                Text("\(settings.sessionsBeforeLongBreak)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(PDS.Colors.focusRed)
                    .frame(width: 24)
            }

            HStack {
                Label(language.settings.dailyGoal, systemImage: "target")
                Spacer()
                Stepper("\(settings.dailyGoal)", value: $settings.dailyGoal, in: 1...20)
                    .labelsHidden()
                Text("\(settings.dailyGoal)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(PDS.Colors.focusRed)
                    .frame(width: 28)
            }
        } header: {
            Label(language.settings.timer, systemImage: "timer")
        }
    }

    private var behaviorSection: some View {
        Section {
            Toggle(isOn: $settings.autoStartBreaks) {
                Label(language.settings.autoStartBreaks, systemImage: "play.circle")
            }
            Toggle(isOn: $settings.autoStartFocus) {
                Label(language.settings.autoStartFocus, systemImage: "arrow.clockwise.circle")
            }
        } header: {
            Label(language.settings.behavior, systemImage: "gearshape")
        }
    }

    private var languageSection: some View {
        Section {
            Picker(selection: Binding(
                get: { language.current },
                set: { language.current = $0 }
            )) {
                ForEach(LanguageOption.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            } label: {
                Label(language.settings.languageSetting, systemImage: "globe")
            }
        }
    }

    private var soundSection: some View {
        Section {
            Toggle(isOn: $settings.soundEnabled) {
                Label(language.settings.sessionSounds, systemImage: "speaker.wave.2.fill")
            }
            Toggle(isOn: $settings.tickingEnabled) {
                Label(language.settings.tickingSound, systemImage: "clock")
            }
            #if os(iOS)
            Toggle(isOn: $settings.hapticEnabled) {
                Label(language.settings.hapticFeedback, systemImage: "iphone.radiowaves.left.and.right")
            }
            #endif

            Picker(selection: $settings.selectedAmbient) {
                ForEach(AmbientSound.allCases) { sound in
                    Label(sound.displayName, systemImage: sound.systemImage)
                        .tag(sound.rawValue)
                }
            } label: {
                Label(language.settings.ambientSound, systemImage: "waveform")
            }
        } header: {
            Label(language.settings.soundAndHaptics, systemImage: "speaker.wave.2")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker(selection: $settings.colorSchemeRaw) {
                Text(language.settings.system).tag(0)
                Text(language.settings.light).tag(1)
                Text(language.settings.dark).tag(2)
            } label: {
                Label(language.settings.appearance, systemImage: "circle.lefthalf.filled")
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $settings.showMotivation) {
                Label(language.settings.motivationalMessages, systemImage: "quote.bubble.fill")
            }
        } header: {
            Label(language.settings.appearance, systemImage: "paintpalette")
        }
    }

    private var notificationsSection: some View {
        Section {
            Toggle(isOn: $settings.notifyOnComplete) {
                Label(language.settings.sessionComplete, systemImage: "bell.fill")
            }
            Toggle(isOn: $settings.notifyBreak) {
                Label(language.settings.breakReminders, systemImage: "bell.badge")
            }
        } header: {
            Label(language.settings.notifications, systemImage: "bell")
        }
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Label(language.settings.version, systemImage: "info.circle")
                Spacer()
                Text(language.settings.appVersion)
                    .foregroundStyle(.secondary)
            }

            Link(destination: URL(string: "https://example.com/pomoro/privacy")!) {
                Label(language.settings.privacyPolicy, systemImage: "hand.raised.fill")
            }

            Link(destination: URL(string: "https://example.com/pomoro/support")!) {
                Label(language.settings.support, systemImage: "questionmark.circle.fill")
            }
        } header: {
            Label(language.settings.about, systemImage: "app.badge")
        }
    }

    private var focusPresetRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(language.settings.focusDuration)
                .font(.body)

            HStack(spacing: 8) {
                ForEach(focusPresets, id: \.self) { preset in
                    Button {
                        settings.focusDuration = preset
                    } label: {
                        Text(language.settings.durationLabel(Int(preset)))
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

    private func durationRow(
        _ label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(language.settings.durationLabel(Int(value.wrappedValue)))
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(PDS.Colors.focusRed)
                .frame(minWidth: 60, alignment: .trailing)
            Stepper("", value: value, in: range, step: 1)
                .labelsHidden()
                .frame(width: 80)
        }
    }
}
