import SwiftUI

struct PomoroTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(TimerViewModel.self) private var timerVM

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, PDS.Spacing.sm)
        .padding(.vertical, PDS.Spacing.sm)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.white.opacity(0.08)),
            alignment: .top
        )
        .padding(.bottom, safeAreaBottomPadding)
    }

    // MARK: - Tab Button

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(PDS.Animation.spring) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(PDS.Colors.focusRed.opacity(0.15))
                            .frame(width: 40, height: 32)
                    }

                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? PDS.Colors.focusRed : Color.secondary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                .frame(height: 32)

                Text(tab.title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular, design: .rounded))
                    .foregroundStyle(selectedTab == tab ? PDS.Colors.focusRed : Color.secondary)

                // Timer indicator dot
                if tab == .timer && timerVM.isRunning {
                    Circle()
                        .fill(PDS.Colors.focusRed)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear.frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PDS.Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var safeAreaBottomPadding: CGFloat {
        #if os(iOS)
        return 0
        #else
        return 0
        #endif
    }
}
