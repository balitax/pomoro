//
//  AuthClient.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation
import Dependencies

struct AuthClient {
    var signInWithApple: @Sendable () -> Void
    var signOut: @Sendable () async -> Void
    var isSignedIn: @Sendable () -> Bool
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        signInWithApple: { DispatchQueue.main.async { AuthService.shared.signInWithApple() } },
        signOut: { await AuthService.shared.signOut() },
        isSignedIn: { AuthService.shared.isSignedIn }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
