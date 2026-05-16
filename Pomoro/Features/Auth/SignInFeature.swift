//
//  SignInFeature.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import ComposableArchitecture

struct SignInFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var isLoading = false
        var error: String?
    }

    enum Action {
        case signInWithAppleTapped
        case signInWithGoogleTapped
        case checkAuthStatus
        case delegate(Delegate)

        enum Delegate {
            case didSignIn
        }
    }

    @Dependency(\.authClient) private var authClient

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .signInWithAppleTapped:
            return .send(.delegate(.didSignIn))

        case .signInWithGoogleTapped:
            return .send(.delegate(.didSignIn))

        case .checkAuthStatus:
            guard state.isLoading else { return .none }
            if authClient.isSignedIn() {
                state.isLoading = false
                return .send(.delegate(.didSignIn))
            }
            return .run { send in
                try await Task.sleep(for: .seconds(0.5))
                await send(.checkAuthStatus)
            }

        case .delegate:
            return .none
        }
    }
}
