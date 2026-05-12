import SwiftUI
import SwiftData
import UserNotifications

@main
struct PomoroApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var authService  = AuthService.shared
    @State private var syncService  = SyncService.shared

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
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                } else if !authService.isSignedIn {
                    SignInView()
                } else {
                    ContentView()
                }
            }
            .animation(.easeInOut(duration: 0.4), value: hasSeenOnboarding)
            .animation(.easeInOut(duration: 0.35), value: authService.isSignedIn)
            .modelContainer(container)
            .environment(authService)
            .environment(syncService)
            .task { await setupSync() }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .modelContainer(container)
                .environment(authService)
                .environment(syncService)
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.window)
        #endif
    }

    // MARK: - Sync Setup

    @MainActor
    private func setupSync() async {
        // Listen ke perubahan auth state
        authService.startListening()

        guard authService.isSignedIn else { return }

        // Inject ModelContext ke SyncService
        let ctx = container.mainContext
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
