//
//  SupabaseService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation
import Supabase

// MARK: - Supabase Client Singleton

final class SupabaseService: @unchecked Sendable {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        guard let url = URL(string: PomoroConfig.supabaseURL),
              !PomoroConfig.supabaseURL.contains("xxxx") else {
            fatalError("""
            ❌ Supabase belum dikonfigurasi!
            Buka Pomoro/Config/PomoroConfig.swift dan isi:
              - supabaseURL   → dari Supabase Dashboard → Settings → API
              - supabaseAnonKey
            """)
        }
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: PomoroConfig.supabaseAnonKey
        )
    }

    // MARK: - Auth State

    var currentUser: User? { client.auth.currentUser }
    var currentUserID: UUID? { client.auth.currentUser?.id }
    var isSignedIn: Bool { client.auth.currentUser != nil }

    // MARK: - Auth Session Stream

    /// Listen ke perubahan auth state (sign in / sign out)
    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        get async {
            await client.auth.authStateChanges
        }
    }
}
