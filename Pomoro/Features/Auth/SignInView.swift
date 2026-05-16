//
//  SignInView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import AuthenticationServices
import ComposableArchitecture

struct SignInView: View {
    @Bindable var store: StoreOf<SignInFeature>
    @Environment(Language.self) private var language

    @State private var appear = false

    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .ignoresSafeArea(.keyboard)
        .onAppear { appear = true }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Circle()
                .fill(PDS.Colors.focusRed.opacity(0.06))
                .frame(width: 320)
                .blur(radius: 100)
                .offset(x: -100, y: -240)

            Circle()
                .fill(PDS.Colors.longBreakBlue.opacity(0.04))
                .frame(width: 260)
                .blur(radius: 80)
                .offset(x: 140, y: -100)

            Circle()
                .fill(Color.orange.opacity(0.04))
                .frame(width: 220)
                .blur(radius: 70)
                .offset(x: -60, y: 280)
        }
    }

    // MARK: - Content

    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()

            heroSection
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appear)

            Spacer()

            actionsSection
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appear)
                .padding(.bottom, 50)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PDS.Colors.focusRed.opacity(0.1))
                    .frame(width: 130, height: 130)
                    .blur(radius: 20)

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
            }

            Text(language.signIn.appName)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text(language.signIn.tagline)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            appleButton
            googleButton

            if let error = store.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            legalText
                .padding(.top, 8)
        }
        .padding(.horizontal, 24)
    }

    private var appleButton: some View {
        Button {
            store.send(.signInWithAppleTapped)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "apple.logo")
                    .font(.system(size: 18))
                Text(language.signIn.continueWithApple)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var googleButton: some View {
        Button {
            store.send(.signInWithGoogleTapped)
        } label: {
            HStack(spacing: 10) {
                GoogleGIcon()
                    .frame(width: 18, height: 18)
                Text(language.signIn.continueWithGoogle)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .foregroundStyle(.black)
        }
        .buttonStyle(.plain)
    }

    private var legalText: some View {
        Group {
            Text(language.signIn.legalPrefix)
            + Text(language.signIn.termsOfService).underline()
            + Text(language.signIn.and)
            + Text(language.signIn.privacyPolicy).underline()
            + Text(language.signIn.period)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
}

#Preview {
    SignInView(store: Store(initialState: SignInFeature.State()) { SignInFeature() })
}
