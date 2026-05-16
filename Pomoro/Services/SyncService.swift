//
//  SyncService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import Foundation
import SwiftData
import Supabase

// MARK: - Sync Service

/// Layer sync antara SwiftData (lokal) dan Supabase (cloud).
/// Strategy: offline-first — tulis ke SwiftData dulu, push ke Supabase async.
/// Pada app launch: pull remote → merge ke lokal (server wins untuk konflik).
@Observable
final class SyncService {
    static let shared = SyncService()

    // MARK: - State

    enum SyncState: Equatable {
        case idle
        case syncing
        case error(String)
    }

    var state: SyncState = .idle
    var lastSyncDate: Date? = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date

    // MARK: - Private

    private let db = SupabaseService.shared.client
    private var modelContext: ModelContext?
    private let tableTasks    = "pomodoro_tasks"
    private let tableSessions = "pomodoro_sessions"

    private init() {}

    func setModelContext(_ ctx: ModelContext) {
        self.modelContext = ctx
    }

    // MARK: - Push (Lokal → Supabase)

    /// Upsert satu task ke Supabase
    func pushTask(_ task: PomodoroTask) {
        guard let userID = SupabaseService.shared.currentUserID else { return }
        let dto = TaskDTO(from: task, userID: userID)
        Task {
            do {
                try await db
                    .from(tableTasks)
                    .upsert(dto, onConflict: "id")
                    .execute()
            } catch {
                print("⚠️ SyncService.pushTask error:", error.localizedDescription)
            }
        }
    }

    /// Upsert satu session ke Supabase (sessions umumnya append-only)
    func pushSession(_ session: PomodoroSession) {
        guard let userID = SupabaseService.shared.currentUserID else { return }
        let dto = SessionDTO(from: session, userID: userID)
        Task {
            do {
                try await db
                    .from(tableSessions)
                    .upsert(dto, onConflict: "id")
                    .execute()
            } catch {
                print("⚠️ SyncService.pushSession error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Local Save

    @MainActor
    func saveSessionLocally(sessionType: SessionType, duration: TimeInterval, actualDuration: TimeInterval, taskID: UUID?) {
        guard let ctx = modelContext else { return }
        let task = taskID.flatMap { id in
            try? ctx.fetch(FetchDescriptor<PomodoroTask>(
                predicate: #Predicate { $0.id == id }
            )).first
        }
        let session = PomodoroSession(sessionType: sessionType, duration: duration, task: task)
        session.complete(actualDuration: actualDuration)
        ctx.insert(session)
        try? ctx.save()
        pushSession(session)
    }

    /// Tandai task sebagai deleted di Supabase (soft delete via is_completed)
    /// Untuk hard delete, kita cukup delete row-nya
    func deleteTask(id: UUID) {
        guard SupabaseService.shared.isSignedIn else { return }
        Task {
            do {
                try await db
                    .from(tableTasks)
                    .delete()
                    .eq("id", value: id.uuidString)
                    .execute()
            } catch {
                print("⚠️ SyncService.deleteTask error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Pull (Supabase → Lokal)

    /// Pull semua data dari Supabase dan merge ke SwiftData.
    /// Dipanggil saat app launch, foreground, atau setelah sign-in.
    func pullAll() async {
        guard let userID = SupabaseService.shared.currentUserID,
              let ctx = modelContext else { return }

        await MainActor.run { state = .syncing }

        do {
            async let remoteTasks    = fetchRemoteTasks(userID: userID)
            async let remoteSessions = fetchRemoteSessions(userID: userID)

            let (tasks, sessions) = try await (remoteTasks, remoteSessions)

            await MainActor.run {
                mergeTasks(tasks, into: ctx)
                mergeSessions(sessions, into: ctx)
                try? ctx.save()
                state = .idle
                lastSyncDate = Date()
                UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
            }
        } catch {
            await MainActor.run {
                state = .error(error.localizedDescription)
                print("⚠️ SyncService.pullAll error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Realtime Subscription

    /// Subscribe ke perubahan realtime dari Supabase.
    /// Dipanggil sekali saat app berjalan — otomatis menerima perubahan dari device lain.
    func startRealtimeSync() {
        guard let userID = SupabaseService.shared.currentUserID,
              let ctx = modelContext else { return }

        let channel = db.realtimeV2.channel("pomoro-sync-\(userID)")

        Task {
            // Subscribe task changes
            let taskChanges = await channel.postgresChange(
                AnyAction.self,
                schema: "public",
                table: tableTasks,
                filter: "user_id=eq.\(userID.uuidString)"
            )

            await channel.subscribe()

            for await change in taskChanges {
                await handleRealtimeTaskChange(change, ctx: ctx)
            }
        }
    }

    // MARK: - Private Fetch

    private func fetchRemoteTasks(userID: UUID) async throws -> [TaskDTO] {
        try await db
            .from(tableTasks)
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
    }

    private func fetchRemoteSessions(userID: UUID) async throws -> [SessionDTO] {
        try await db
            .from(tableSessions)
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
    }

    // MARK: - Private Merge (sudah di MainActor)

    private func mergeTasks(_ remote: [TaskDTO], into ctx: ModelContext) {
        let localTasks = (try? ctx.fetch(FetchDescriptor<PomodoroTask>())) ?? []
        let localIndex = Dictionary(uniqueKeysWithValues: localTasks.map { ($0.id, $0) })

        // Remote → lokal
        for dto in remote {
            if let existing = localIndex[dto.id] {
                // Update: server wins (last-write-wins berdasarkan updatedAt)
                dto.apply(to: existing)
            } else {
                // Insert: record baru dari device lain
                let task = PomodoroTask(
                    title: dto.title,
                    notes: dto.notes,
                    estimatedPomodoros: dto.estimatedPomodoros,
                    isToday: dto.isToday,
                    sortOrder: dto.sortOrder
                )
                task.id = dto.id
                task.completedPomodoros = dto.completedPomodoros
                task.isCompleted = dto.isCompleted
                task.completedAt = dto.completedAt
                ctx.insert(task)
            }
        }

        // Lokal-only yang tidak ada di remote → delete (dihapus di device lain)
        let remoteIDs = Set(remote.map { $0.id })
        for task in localTasks where !remoteIDs.contains(task.id) {
            ctx.delete(task)
        }
    }

    private func mergeSessions(_ remote: [SessionDTO], into ctx: ModelContext) {
        let localSessions = (try? ctx.fetch(FetchDescriptor<PomodoroSession>())) ?? []
        let localIndex = Dictionary(uniqueKeysWithValues: localSessions.map { ($0.id, $0) })

        // Sessions: append-only — hanya tambah yang belum ada lokal
        for dto in remote where localIndex[dto.id] == nil {
            let session = PomodoroSession(
                sessionType: SessionType(rawValue: dto.sessionType) ?? .focus,
                duration: dto.duration
            )
            session.id             = dto.id
            session.actualDuration = dto.actualDuration
            session.startedAt      = dto.startedAt
            session.completedAt    = dto.completedAt
            session.wasCompleted   = dto.wasCompleted
            ctx.insert(session)
        }
    }

    // MARK: - Realtime Handler

    @MainActor
    private func handleRealtimeTaskChange(_ change: AnyAction, ctx: ModelContext) {
        // Re-pull saat ada perubahan realtime — simple approach
        // Bisa dioptimasi dengan apply perubahan spesifik
        Task { await pullAll() }
    }
}
