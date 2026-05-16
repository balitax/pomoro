//
//  AppTab.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case timer
    case tasks
    case stats
    case settings

    var id: String { rawValue }

    var title: String {
        Language.shared.tabs.title(for: self)
    }

    var icon: String {
        switch self {
        case .timer: "timer"
        case .tasks: "checklist"
        case .stats: "chart.bar"
        case .settings: "gearshape"
        }
    }

    var selectedIcon: String {
        switch self {
        case .timer: "timer.circle.fill"
        case .tasks: "checklist.circle.fill"
        case .stats: "chart.bar.fill"
        case .settings: "gearshape.fill"
        }
    }
}
