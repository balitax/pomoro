//
//  MainTabCoordinator.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import ComposableArchitecture
import SwiftUI

struct MainTabCoordinator: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedTab: AppTab = .timer
        var showFocusMode = false
        var focus = FocusFeature.State()
    }

    @CasePathable
    enum Action {
        case tabSelected(AppTab)
        case setShowFocusMode(Bool)
        case focus(FocusFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.focus, action: \.focus) {
            FocusFeature()
        }

        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none

            case .setShowFocusMode(let show):
                guard state.showFocusMode != show else { return .none }
                state.showFocusMode = show
                if !show {
                    state.focus.isFocusModeRequested = false
                }
                return .none

            case .focus(.toggleFocusMode):
                state.showFocusMode = true
                return .none

            case .focus:
                return .none
            }
        }
    }
}
