import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var timerVM = TimerViewModel()
    @State private var taskVM = TaskViewModel()
    @State private var statsVM = StatisticsViewModel()
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
        .environment(timerVM)
        .environment(taskVM)
        .environment(statsVM)
        .fullScreenCover(isPresented: $showFocusMode) {
            FocusModeView(isPresented: $showFocusMode)
                .environment(timerVM)
                .environment(taskVM)
        }
        .onChange(of: timerVM.isFocusModeRequested) { _, requested in
            if requested {
                showFocusMode = true
                timerVM.isFocusModeRequested = false
            }
        }
    }

    // MARK: - iOS Layout

    @ViewBuilder
    private var iOSLayout: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TimerView()
                    .tag(AppTab.timer)
                TaskListView()
                    .tag(AppTab.tasks)
                StatisticsView()
                    .tag(AppTab.stats)
                SettingsView()
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PomoroTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - macOS Layout

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
        case .timer: TimerView()
        case .tasks: TaskListView()
        case .stats: StatisticsView()
        case .settings: SettingsView()
        }
    }
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
