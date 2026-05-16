//
//  AppFeature.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import CasePaths
import ComposableArchitecture
import SwiftUI

struct AppFeature: Reducer {

    enum Path: Equatable {
        case onboarding
        case signIn
        case main
    }

    @ObservableState
    struct State: Equatable {
        var path: Path
        var onboarding = OnboardingFeature.State()
        var signIn = SignInFeature.State()
        var mainTab = MainTabCoordinator.State()

        init() {
            if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                path = .signIn
            } else {
                path = .onboarding
            }
        }
    }

    @CasePathable
    enum Action {
        case checkOnboarding
        case checkAuth
        case onboarding(OnboardingFeature.Action)
        case signIn(SignInFeature.Action)
        case mainTab(MainTabCoordinator.Action)
    }

    @Dependency(\.authClient) private var authClient

    var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        Scope(state: \.signIn, action: \.signIn) {
            SignInFeature()
        }
        Scope(state: \.mainTab, action: \.mainTab) {
            MainTabCoordinator()
        }

        Reduce { state, action in
            switch action {
            case .checkOnboarding:
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    state.path = .signIn
                }
                return .none

            case .checkAuth:
                if authClient.isSignedIn() {
                    state.path = .main
                }
                return .none

            case .onboarding(.delegate(.didComplete)):
                state.path = .signIn
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                return .none

            case .signIn(.delegate(.didSignIn)):
                state.path = .main
                return .none

            case .onboarding:
                return .none
            case .signIn:
                return .none
            case .mainTab:
                return .none
            }
        }
    }
}
