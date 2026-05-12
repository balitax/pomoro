import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var authService = AuthService.shared
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: "#0A0A0B"), Color(hex: "#141416")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + title
                VStack(spacing: PDS.Spacing.lg) {
                    PomoroLogo(size: 72)
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                        .animation(PDS.Animation.bouncy.delay(0.1), value: appeared)

                    VStack(spacing: PDS.Spacing.sm) {
                        Text("Welcome to Pomoro")
                            .font(PDS.Typography.heroTitle)
                            .foregroundStyle(.primary)

                        Text("Sign in to sync your sessions\nacross iPhone and Mac")
                            .font(PDS.Typography.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .offset(y: appeared ? 0 : 20)
                    .opacity(appeared ? 1 : 0)
                    .animation(PDS.Animation.smooth.delay(0.2), value: appeared)
                }

                Spacer()

                // Features
                VStack(spacing: PDS.Spacing.sm) {
                    featureRow(icon: "iphone.and.ipad", text: "Sync antara iPhone & Mac")
                    featureRow(icon: "chart.bar.fill",  text: "Statistik tersimpan permanen")
                    featureRow(icon: "lock.shield.fill", text: "Data privat, hanya milikmu")
                }
                .padding(.horizontal, PDS.Spacing.xl)
                .padding(.bottom, PDS.Spacing.xl)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)
                .animation(PDS.Animation.smooth.delay(0.3), value: appeared)

                // Sign In Button
                VStack(spacing: PDS.Spacing.md) {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { _ in },
                        onCompletion: { _ in }
                    )
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: PDS.Radius.large, style: .continuous))
                    .onTapGesture { authService.signInWithApple() }
                    .disabled(authService.isLoading)
                    .overlay {
                        if authService.isLoading {
                            RoundedRectangle(cornerRadius: PDS.Radius.large)
                                .fill(Color.black.opacity(0.3))
                            ProgressView()
                                .tint(.white)
                        }
                    }

                    // Error message
                    if let error = authService.error {
                        Text(error)
                            .font(PDS.Typography.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Text("Dengan sign in, kamu setuju dengan Syarat Layanan\ndan Kebijakan Privasi kami.")
                        .font(PDS.Typography.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, PDS.Spacing.xl)
                .padding(.bottom, PDS.Spacing.xxl)
                .offset(y: appeared ? 0 : 20)
                .opacity(appeared ? 1 : 0)
                .animation(PDS.Animation.smooth.delay(0.4), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: PDS.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PDS.Colors.focusRed)
                .frame(width: 28)

            Text(text)
                .font(PDS.Typography.callout)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(PDS.Spacing.md)
        .glassBackground(cornerRadius: PDS.Radius.medium)
    }
}

// MARK: - Sync Status Indicator

struct SyncStatusView: View {
    let syncService: SyncService

    var body: some View {
        HStack(spacing: 6) {
            switch syncService.state {
            case .idle:
                if let date = syncService.lastSyncDate {
                    Image(systemName: "checkmark.icloud.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.green)
                    Text("Synced \(date.formatted(.relative(presentation: .named)))")
                        .font(PDS.Typography.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "icloud.slash")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text("Not synced")
                        .font(PDS.Typography.caption2)
                        .foregroundStyle(.secondary)
                }
            case .syncing:
                ProgressView()
                    .scaleEffect(0.7)
                Text("Syncing...")
                    .font(PDS.Typography.caption2)
                    .foregroundStyle(.secondary)
            case .error(let msg):
                Image(systemName: "exclamationmark.icloud.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
                Text(msg)
                    .font(PDS.Typography.caption2)
                    .foregroundStyle(.orange)
                    .lineLimit(1)
            }
        }
    }
}
