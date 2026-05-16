//
//  OnboardingView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI

// MARK: - Onboarding Root

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    private let pages = OnboardingPage.allPages

    var body: some View {
        VStack(spacing: 0) {

            // Skip
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        hasSeenOnboarding = true
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .frame(height: 48)

            // Page content
            OnboardingPageView(page: pages[currentPage])
                .id(currentPage)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.28), value: currentPage)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dot indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: i == currentPage ? 20 : 7, height: 7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
            }
            .padding(.bottom, 20)

            // CTA button
            Button {
                withAnimation {
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                    } else {
                        hasSeenOnboarding = true
                    }
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
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

// MARK: - Page View

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

// MARK: - Page Model

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Focus on What Matters",
            subtitle: "Use the proven Pomodoro technique to work deeply and recharge intentionally.",
            icon: "timer"
        ),
        OnboardingPage(
            title: "Manage Your Tasks",
            subtitle: "Capture what needs to get done and link tasks directly to your focus sessions.",
            icon: "checklist"
        ),
        OnboardingPage(
            title: "Track Your Progress",
            subtitle: "Daily streaks and insightful charts keep you motivated and on track.",
            icon: "chart.bar.fill"
        ),
    ]
}

// MARK: - Shared Shapes (used by SignInView)

struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: width / 2)
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.midY),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        return path
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
