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
    @Environment(Language.self) private var language

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(language.info.appName)
                            .font(.title.bold())

                        Text(language.info.versionLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(language.info.featureRows, id: \.title) { row in
                            infoRow(icon: row.icon, title: row.title, subtitle: row.subtitle)
                            if row.title != language.info.featureRows.last?.title {
                                Divider().padding(.leading, 58)
                            }
                        }
                    }
                    .background(Color.platformSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(spacing: 4) {
                        Text(language.info.madeWithLove)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(language.info.copyright)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 16)
            }
            .background(Color.platformBackground)
            .navigationTitle(language.info.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(language.common.done) { dismiss() }
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
