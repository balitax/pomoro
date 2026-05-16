//
//  StatisticsView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Environment(StatisticsViewModel.self) private var statsVM
    @Query private var allSessions: [PomodoroSession]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0A0A0B").ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: PDS.Spacing.md) {

                        // Today headline
                        todaySection

                        // Weekly chart
                        weeklyChartSection

                        // All-time stats
                        allTimeSection

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, PDS.Spacing.md)
                    .padding(.top, PDS.Spacing.md)
                }
            }
            .navigationTitle("Statistics")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            statsVM.load(sessions: allSessions)
        }
        .onChange(of: allSessions.count) { _, _ in
            statsVM.load(sessions: allSessions)
        }
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
            sectionTitle("Today")

            // Daily Goal card
            dailyGoalCard

            // Stat chips row
            HStack(spacing: PDS.Spacing.md) {
                StatCard(
                    value: statsVM.totalFocusTodayFormatted,
                    label: "Focus Time",
                    icon: "clock.fill",
                    color: PDS.Colors.longBreakBlue
                )
                StatCard(
                    value: "\(statsVM.currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: Color.orange
                )
            }
        }
    }

    // MARK: - Daily Goal Card

    private var dailyGoalCard: some View {
        HStack(spacing: 20) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(PDS.Colors.focusRed.opacity(0.12), lineWidth: 10)
                    .frame(width: 84, height: 84)
                Circle()
                    .trim(from: 0, to: statsVM.dailyGoalProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#FF6B6B"), PDS.Colors.focusRed],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 84, height: 84)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75),
                               value: statsVM.dailyGoalProgress)

                VStack(spacing: 0) {
                    Text("\(statsVM.completedTodayCount)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("/ \(statsVM.dailyGoal)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Goal")
                        .font(.system(size: 15, weight: .semibold))
                    Text(statsVM.dailyGoalProgress >= 1
                         ? "Goal reached! 🎉"
                         : "\(statsVM.dailyGoal - statsVM.completedTodayCount) sessions to go")
                        .font(.caption)
                        .foregroundStyle(statsVM.dailyGoalProgress >= 1
                                         ? PDS.Colors.breakGreen
                                         : Color.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(PDS.Colors.focusRed.opacity(0.12))
                            .frame(height: 5)
                        Capsule()
                            .fill(PDS.Colors.focusRed)
                            .frame(width: geo.size.width * statsVM.dailyGoalProgress, height: 5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.75),
                                       value: statsVM.dailyGoalProgress)
                    }
                }
                .frame(height: 5)
            }

            Spacer()
        }
        .padding(PDS.Spacing.md)
        .glassBackground()
    }

    // MARK: - Weekly Chart

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
            sectionTitle("This Week")

            VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
                Chart(statsVM.weeklyData) { day in
                    BarMark(
                        x: .value("Day", day.dayLabel),
                        y: .value("Pomodoros", day.pomodoroCount)
                    )
                    .foregroundStyle(
                        day.isToday
                            ? LinearGradient(colors: PDS.Colors.focusRed.gradientLike, startPoint: .bottom, endPoint: .top)
                            : LinearGradient(colors: [Color.secondary.opacity(0.3)], startPoint: .bottom, endPoint: .top)
                    )
                    .cornerRadius(6)
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            Text(value.as(String.self) ?? "")
                                .font(PDS.Typography.caption2)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .chartYAxis(.hidden)
            }
            .padding(PDS.Spacing.md)
            .glassBackground()
        }
    }

    // MARK: - All Time Section

    private var allTimeSection: some View {
        VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
            sectionTitle("All Time")

            HStack(spacing: PDS.Spacing.md) {
                StatCard(
                    value: "\(statsVM.totalAllTime)",
                    label: "Pomodoros",
                    icon: "checkmark.seal.fill",
                    color: PDS.Colors.breakGreen
                )
                StatCard(
                    value: statsVM.averageDailyFocus,
                    label: "Daily Avg",
                    icon: "calendar.badge.clock",
                    color: Color.purple
                )
            }
        }
    }

    // MARK: - Section Title

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .tracking(1.5)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: PDS.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .padding(8)
                .background(color.opacity(0.12), in: Circle())

            Spacer()

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(PDS.Typography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PDS.Spacing.md)
        .frame(height: 110)
        .glassBackground()
    }
}

// MARK: - Color Extension for Charts

extension Color {
    var gradientLike: [Color] { [self.opacity(0.7), self] }
}
