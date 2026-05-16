//
//  OnboardingView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>
    @Environment(Language.self) private var language

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !store.isLastPage {
                    Button(language.common.skip) {
                        store.send(.skipTapped)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .frame(height: 48)

            OnboardingPageView(
                icon: store.pages[store.currentPage].icon,
                title: language.onboarding.pageTitle(index: store.currentPage),
                subtitle: language.onboarding.pageSubtitle(index: store.currentPage)
            )
            .id(store.currentPage)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal:   .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.28), value: store.currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 8) {
                ForEach(0..<store.pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == store.currentPage ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: i == store.currentPage ? 20 : 7, height: 7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: store.currentPage)
                }
            }
            .padding(.bottom, 20)

            Button {
                store.send(.nextTapped)
            } label: {
                Text(store.isLastPage ? language.onboarding.getStarted : language.common.continue)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
            VStack(spacing: 12) {
                Text(title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }
}

struct OnboardingPage: Equatable {
    let icon: String

    static let allPages: [OnboardingPage] = [
        OnboardingPage(icon: "timer"),
        OnboardingPage(icon: "checklist"),
        OnboardingPage(icon: "chart.bar.fill"),
    ]
}

#Preview {
    OnboardingView(store: Store(initialState: OnboardingFeature.State()) { OnboardingFeature() })
}
