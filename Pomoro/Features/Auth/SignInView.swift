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

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                Text(language.signIn.appName)
                    .font(.largeTitle.bold())
                Text(language.signIn.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 10) {
                Button {
                    store.send(.signInWithAppleTapped)
                } label: {
                    Label(language.signIn.continueWithApple, systemImage: "apple.logo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    store.send(.signInWithGoogleTapped)
                } label: {
                    HStack(spacing: 8) {
                        GoogleGIcon().frame(width: 16, height: 16)
                        Text(language.signIn.continueWithGoogle)
                            .foregroundStyle(Color.primary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                if let error = store.error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)

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
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    SignInView(store: Store(initialState: SignInFeature.State()) { SignInFeature() })
}
