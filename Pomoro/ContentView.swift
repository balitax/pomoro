//
//  ContentView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(TimerViewModel.self) private var timerVM
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(StatisticsViewModel.self) private var statsVM
    @State private var selectedTab: AppTab = .timer
    @State private var showFocusMode = false

    var body: some View {
        Group {
            #if os(iOS)
            iOSLayout
            #else
            macOSLayout
            #endif
        }
        .tint(PDS.Colors.focusRed)
        #if os(iOS)
        .fullScreenCover(isPresented: $showFocusMode) {
            FocusModeView(isPresented: $showFocusMode)
                .environment(timerVM)
                .environment(taskVM)
        }
        #endif
        .onChange(of: timerVM.isFocusModeRequested) { _, requested in
            if requested {
                showFocusMode = true
                timerVM.isFocusModeRequested = false
            }
        }
    }

    // MARK: - iOS Layout

    #if os(iOS)
    @ViewBuilder
    private var iOSLayout: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { TimerView() }
                .tag(AppTab.timer)
            NavigationStack { TaskListView() }
                .tag(AppTab.tasks)
            NavigationStack { StatisticsView() }
                .tag(AppTab.stats)
            NavigationStack { SettingsView() }
                .tag(AppTab.settings)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .overlay(alignment: .bottom) {
            PomoroTabBar(selectedTab: $selectedTab)
        }
    }
    #endif

    // MARK: - macOS Layout

    #if os(macOS)
    @ViewBuilder
    private var macOSLayout: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            macOSSidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 260)
        } detail: {
            macOSDetail
        }
        .frame(minWidth: 800, minHeight: 600)
    }

    @ViewBuilder
    private var macOSSidebar: some View {
        List(AppTab.allCases, selection: $selectedTab) { tab in
            Label(tab.title, systemImage: tab.selectedIcon)
                .tag(tab)
        }
        .listStyle(.sidebar)
        .navigationTitle("Pomoro")
    }

    @ViewBuilder
    private var macOSDetail: some View {
        switch selectedTab {
        case .timer:    TimerView()
        case .tasks:    TaskListView()
        case .stats:    StatisticsView()
        case .settings: SettingsView()
        }
    }
    #endif
}

// MARK: - App Tab

enum AppTab: String, CaseIterable, Identifiable {
    case timer, tasks, stats, settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timer: "Focus"
        case .tasks: "Tasks"
        case .stats: "Stats"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .timer: "timer"
        case .tasks: "checklist"
        case .stats: "chart.bar"
        case .settings: "gearshape"
        }
    }

    var selectedIcon: String {
        switch self {
        case .timer: "timer"
        case .tasks: "checklist.checked"
        case .stats: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }
}
