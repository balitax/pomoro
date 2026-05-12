import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    @State private var isAnimating = false

    private let pages = OnboardingPage.allPages

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "#0E0E0F"), Color(hex: "#1A1A1C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(PDS.Animation.smooth) {
                                hasSeenOnboarding = true
                            }
                        }
                        .font(PDS.Typography.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                }

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(PDS.Animation.smooth, value: currentPage)

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? PDS.Colors.focusRed : Color.secondary.opacity(0.3))
                            .frame(width: i == currentPage ? 20 : 7, height: 7)
                            .animation(PDS.Animation.spring, value: currentPage)
                    }
                }
                .padding(.bottom, PDS.Spacing.xl)

                // CTA button
                Button {
                    withAnimation(PDS.Animation.spring) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            pages[currentPage].accentColor,
                            in: RoundedRectangle(cornerRadius: PDS.Radius.large, style: .continuous)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, PDS.Spacing.xl)
                .padding(.bottom, PDS.Spacing.xxl)
            }
        }
    }
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: PDS.Spacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 140, height: 140)

                Image(systemName: page.systemImage)
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(page.accentColor)
                    .symbolEffect(.pulse, isActive: appeared)
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(PDS.Animation.bouncy.delay(0.1), value: appeared)

            // Text
            VStack(spacing: PDS.Spacing.sm) {
                Text(page.title)
                    .font(PDS.Typography.title1)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(PDS.Animation.smooth.delay(0.2), value: appeared)

                Text(page.subtitle)
                    .font(PDS.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(PDS.Animation.smooth.delay(0.3), value: appeared)
            }
            .padding(.horizontal, PDS.Spacing.xl)

            Spacer()
        }
        .onAppear { appeared = true }
        .onDisappear { appeared = false }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let title: String
    let subtitle: String
    let systemImage: String
    let accentColor: Color

    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Deep Focus,\nBetter Work",
            subtitle: "Use the Pomodoro technique to build focused work sessions and regular breaks.",
            systemImage: "flame.fill",
            accentColor: PDS.Colors.focusRed
        ),
        OnboardingPage(
            title: "Track Your\nProgress",
            subtitle: "See how many pomodoros you complete each day and build a powerful streak.",
            systemImage: "chart.bar.fill",
            accentColor: PDS.Colors.longBreakBlue
        ),
        OnboardingPage(
            title: "Link Tasks\nto Sessions",
            subtitle: "Stay intentional by connecting your tasks to each focus session.",
            systemImage: "checklist.checked",
            accentColor: PDS.Colors.breakGreen
        ),
        OnboardingPage(
            title: "Works on\niPhone & Mac",
            subtitle: "Your sessions, tasks, and stats sync seamlessly across all your devices.",
            systemImage: "iphone.and.ipad",
            accentColor: Color.purple
        )
    ]
}
