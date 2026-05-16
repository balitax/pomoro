//
//  PomoroApp.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PomoroApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var authService  = AuthService.shared
    @State private var syncService  = SyncService.shared
    @State private var timerVM      = TimerViewModel()
    @State private var taskVM       = TaskViewModel()
    @State private var statsVM      = StatisticsViewModel()

    let container: ModelContainer

    init() {
        do {
            let schema = Schema([PomodoroTask.self, PomodoroSession.self])
            // Tidak pakai cloudKitDatabase — sync ditangani Supabase
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer initialization failed: \(error)")
        }
        requestNotificationPermission()
    }

    var body: some Scene {
        #if os(macOS)
        WindowGroup { rootContent }
            .windowStyle(.hiddenTitleBar)
            .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .modelContainer(container)
                .environment(timerVM)
                .environment(taskVM)
                .environment(authService)
                .environment(syncService)
        } label: {
            MenuBarLabel()
                .environment(timerVM)
        }
        .menuBarExtraStyle(.window)
        #else
        WindowGroup { rootContent }
        #endif
    }

    @MainActor @ViewBuilder
    private var rootContent: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            } else if !authService.isSignedIn {
                SignInView()
            } else {
                ContentView()
            }
        }
        .preferredColorScheme(.light)
        .animation(.easeInOut(duration: 0.4), value: hasSeenOnboarding)
        .animation(.easeInOut(duration: 0.35), value: authService.isSignedIn)
        .modelContainer(container)
        .environment(timerVM)
        .environment(taskVM)
        .environment(statsVM)
        .environment(authService)
        .environment(syncService)
        .task { await setupSync() }
    }

    // MARK: - Sync Setup

    @MainActor
    private func setupSync() async {
        // Listen ke perubahan auth state
        authService.startListening()

        // Inject ModelContext ke ViewModels
        let ctx = container.mainContext
        timerVM.setModelContext(ctx)
        taskVM.setModelContext(ctx)

        guard authService.isSignedIn else { return }

        // Inject ModelContext ke SyncService
        syncService.setModelContext(ctx)

        // Pull data terbaru dari Supabase
        await syncService.pullAll()

        // Mulai Realtime subscription
        syncService.startRealtimeSync()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }
}
