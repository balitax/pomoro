import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        VStack(spacing: PDS.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(Color.secondary.opacity(0.5))
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(PDS.Animation.bouncy.delay(0.05), value: appeared)

            VStack(spacing: PDS.Spacing.xs) {
                Text(title)
                    .font(PDS.Typography.title3)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(PDS.Typography.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .offset(y: appeared ? 0 : 12)
            .opacity(appeared ? 1 : 0)
            .animation(PDS.Animation.smooth.delay(0.12), value: appeared)

            if let title = actionTitle, let action {
                Button(action: action) {
                    Text(title)
                        .font(PDS.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(PDS.Colors.focusRed)
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .animation(PDS.Animation.smooth.delay(0.2), value: appeared)
            }
        }
        .padding(PDS.Spacing.xl)
        .frame(maxWidth: 280)
        .onAppear { appeared = true }
    }
}
