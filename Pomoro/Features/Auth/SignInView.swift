//
//  SignInView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025
//

import SwiftUI
import AuthenticationServices

// MARK: - Sign In View

struct SignInView: View {
    @State private var authService = AuthService.shared

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero
            VStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)

                Text("Pomoro")
                    .font(.largeTitle.bold())

                Text("Focus beautifully.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Sign in options
            VStack(spacing: 10) {
                // Apple Sign In
                Button {
                    authService._devBypass = true
                } label: {
                    Label("Continue with Apple", systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Google Sign In (coming soon)
                Button {
                    authService._devBypass = true
                } label: {
                    HStack(spacing: 8) {
                        GoogleGIcon().frame(width: 16, height: 16)
                        Text("Continue with Google")
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                // Error
                if let error = authService.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

            // Terms
            Group {
                Text("By continuing, you agree to our ")
                + Text("Terms of Service").underline()
                + Text(" and ")
                + Text("Privacy Policy").underline()
                + Text(".")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
}


#Preview {
    SignInView()
}
