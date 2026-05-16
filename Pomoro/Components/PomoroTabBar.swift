//
//  PomoroTabBar.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


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
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 28)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Tab Button

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(selectedTab == tab ? PDS.Colors.focusRed : Color.secondary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                        .frame(width: 24, height: 24)

                    // Running indicator dot
                    if tab == .timer && timerVM.isRunning {
                        Circle()
                            .fill(PDS.Colors.focusRed)
                            .frame(width: 7, height: 7)
                            .offset(x: 4, y: -2)
                    }
                }

                Text(tab.title)
                    .font(.system(size: 10,
                                  weight: selectedTab == tab ? .semibold : .regular,
                                  design: .rounded))
                    .foregroundStyle(selectedTab == tab ? PDS.Colors.focusRed : Color.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                selectedTab == tab
                    ? PDS.Colors.focusRed.opacity(0.1)
                    : Color.clear,
                in: Capsule()
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selectedTab)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
