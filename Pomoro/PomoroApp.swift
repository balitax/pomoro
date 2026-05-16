//
//  PomoroApp.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import SwiftData
import UserNotifications
import ComposableArchitecture

@main
struct PomoroApp: App {
    @State private var authService  = AuthService.shared
    @State private var syncService  = SyncService.shared
    @State private var timerVM      = TimerViewModel()
    @State private var taskVM       = TaskViewModel()
    @State private var statsVM      = StatisticsViewModel()

    @State private var store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }

    let container: ModelContainer

    init() {
        do {
            let schema = Schema([PomodoroTask.self, PomodoroSession.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("ModelContainer initialization failed: \(error)")
        }
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .preferredColorScheme(.light)
                .modelContainer(container)
                .environment(taskVM)
                .environment(statsVM)
                .environment(timerVM)
                .environment(authService)
                .environment(syncService)
                .task { await setupSync() }
        }
    }

    @MainActor
    private func setupSync() async {
        store.send(.checkOnboarding)
        store.send(.checkAuth)

        authService.startListening()

        let ctx = container.mainContext
        taskVM.setModelContext(ctx)

        guard authService.isSignedIn else { return }
        syncService.setModelContext(ctx)
        await syncService.pullAll()
        syncService.startRealtimeSync()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }
}

// MARK: - App View

struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        Group {
            switch store.path {
            case .onboarding:
                OnboardingView(
                    store: store.scope(state: \.onboarding, action: \.onboarding)
                )
            case .signIn:
                SignInView(
                    store: store.scope(state: \.signIn, action: \.signIn)
                )
            case .main:
                ContentView(
                    store: store.scope(state: \.mainTab, action: \.mainTab)
                )
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.path)
    }
}
