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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                if !store.isLastPage {
                    Button("Skip") {
                        store.send(.skipTapped)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .frame(height: 48)

            OnboardingPageView(page: store.pages[store.currentPage])
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
                Text(store.isLastPage ? "Get Started" : "Continue")
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
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(.tint)
                .symbolRenderingMode(.hierarchical)
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
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
    let title: String
    let subtitle: String
    let icon: String

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: String(localized: "Focus on What Matters"),
            subtitle: String(localized: "Use the proven Pomodoro technique to work deeply and recharge intentionally."),
            icon: "timer"
        ),
        OnboardingPage(
            title: String(localized: "Manage Your Tasks"),
            subtitle: String(localized: "Capture what needs to get done and link tasks directly to your focus sessions."),
            icon: "checklist"
        ),
        OnboardingPage(
            title: String(localized: "Track Your Progress"),
            subtitle: String(localized: "Daily streaks and insightful charts keep you motivated and on track."),
            icon: "chart.bar.fill"
        ),
    ]
}

#Preview {
    OnboardingView(store: Store(initialState: OnboardingFeature.State()) { OnboardingFeature() })
}
