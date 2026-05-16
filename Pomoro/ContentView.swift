//
//  ContentView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct ContentView: View {
    @Environment(TaskViewModel.self) private var taskVM
    @Environment(StatisticsViewModel.self) private var statsVM
    @Bindable var store: StoreOf<MainTabCoordinator>

    var body: some View {
        TabView(selection: Binding(
            get: { store.selectedTab },
            set: { store.send(.tabSelected($0)) }
        )) {
            NavigationStack {
                TimerView(store: store.scope(state: \.focus, action: \.focus))
            }
            .tag(AppTab.timer)

            NavigationStack { TaskListView() }
                .tag(AppTab.tasks)

            NavigationStack { StatisticsView() }
                .tag(AppTab.stats)

            NavigationStack { SettingsView() }
                .tag(AppTab.settings)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
        )
        .overlay(alignment: .bottom) {
            PomoroTabBar(selectedTab: Binding(
                get: { store.selectedTab },
                set: { store.send(.tabSelected($0)) }
            ))
        }
        .tint(PDS.Colors.focusRed)
        .fullScreenCover(isPresented: Binding(
            get: { store.showFocusMode },
            set: { store.send(.setShowFocusMode($0)) }
        )) {
            FocusModeView(
                store: store.scope(state: \.focus, action: \.focus),
                isPresented: Binding(
                    get: { store.showFocusMode },
                    set: { store.send(.setShowFocusMode($0)) }
                )
            )
            .environment(taskVM)
        }
    }
}
