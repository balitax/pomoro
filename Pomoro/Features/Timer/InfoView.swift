//
//  InfoView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // App icon + name
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text("Pomoro")
                            .font(.title.bold())

                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)

                    // Features list
                    VStack(alignment: .leading, spacing: 0) {
                        infoRow(icon: "timer", title: "Pomodoro Timer",
                                subtitle: "Focus sessions with short and long breaks")
                        Divider().padding(.leading, 58)
                        infoRow(icon: "checklist", title: "Task Tracking",
                                subtitle: "Link tasks to your focus sessions")
                        Divider().padding(.leading, 58)
                        infoRow(icon: "chart.bar.fill", title: "Statistics",
                                subtitle: "Track your productivity over time")
                        Divider().padding(.leading, 58)
                        infoRow(icon: "bell.badge", title: "Notifications",
                                subtitle: "Get notified when your session ends")
                        Divider().padding(.leading, 58)
                        infoRow(icon: "macbook.and.iphone", title: "iOS & macOS",
                                subtitle: "Available on all your Apple devices")
                    }
                    .background(Color.platformSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Credits
                    VStack(spacing: 4) {
                        Text("Made with ♥ by Agus Cahyono")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("© 2025 Pomoro. All rights reserved.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.platformBackground)
            .navigationTitle("About Pomoro")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        #endif
    }

    private func infoRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(PDS.Colors.focusRed)
                .frame(width: 34, height: 34)
                .background(PDS.Colors.focusRed.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    InfoView()
}
