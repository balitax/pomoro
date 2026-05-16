//
//  OnboardingFeature.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import ComposableArchitecture
import SwiftUI

struct OnboardingFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var currentPage = 0
        let pages = OnboardingPage.allPages
        var isLastPage: Bool { currentPage == pages.count - 1 }
    }

    enum Action {
        case nextTapped
        case skipTapped
        case delegate(Delegate)

        enum Delegate {
            case didComplete
        }
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .nextTapped:
            if state.currentPage < state.pages.count - 1 {
                state.currentPage += 1
            } else {
                return .send(.delegate(.didComplete))
            }
            return .none

        case .skipTapped:
            return .send(.delegate(.didComplete))

        case .delegate:
            return .none
        }
    }
}
