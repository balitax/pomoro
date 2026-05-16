//
//  AuthService.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import Foundation
import Supabase
import CryptoKit

#if os(iOS)
import AuthenticationServices
import UIKit
#elseif os(macOS)
import AuthenticationServices
import AppKit
#endif

// MARK: - Auth Service

@Observable
final class AuthService: NSObject {
    static let shared = AuthService()

    var currentUser: User? = nil
    // TODO: Remove before release
    var _devBypass: Bool = false
    var isSignedIn: Bool { currentUser != nil || _devBypass }
    var isLoading: Bool = false
    var error: String? = nil

    private let supabase = SupabaseService.shared
    private var currentNonce: String = ""

    override private init() {
        super.init()
        // Restore session dari keychain
        currentUser = supabase.currentUser
    }

    // MARK: - Apple Sign In

    func signInWithApple() {
        isLoading = true
        error = nil
        currentNonce = randomNonce()

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func signOut() async {
        do {
            try await supabase.client.auth.signOut()
            await MainActor.run { currentUser = nil }
        } catch {
            await MainActor.run { self.error = error.localizedDescription }
        }
    }

    // MARK: - Auth State Listener

    func startListening() {
        Task {
            for await (event, session) in await supabase.authStateChanges {
                await MainActor.run {
                    switch event {
                    case .signedIn, .tokenRefreshed:
                        self.currentUser = session?.user
                    case .signedOut, .userDeleted:
                        self.currentUser = nil
                    default:
                        break
                    }
                }
            }
        }
    }

    // MARK: - Nonce Helpers

    private func randomNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            _ = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            randoms.forEach { random in
                guard remainingLength > 0 else { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = appleIDCredential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            DispatchQueue.main.async { self.isLoading = false }
            return
        }

        Task {
            do {
                let session = try await supabase.client.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .apple,
                        idToken: idToken,
                        nonce: currentNonce
                    )
                )
                await MainActor.run {
                    self.currentUser = session.user
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        DispatchQueue.main.async {
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
        #elseif os(macOS)
        NSApplication.shared.windows.first { $0.isKeyWindow } ?? NSWindow()
        #endif
    }
}
