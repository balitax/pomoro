//
//  Strings+Common.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Common

struct CommonStrings: StringsBase {
    let language: LanguageOption
    var cancel: String { localized("Cancel", "Batal") }
    var done: String { localized("Done", "Selesai") }
    var skip: String { localized("Skip", "Lewati") }
    var reset: String { localized("Reset", "Atur Ulang") }
    var `continue`: String { localized("Continue", "Lanjutkan") }
    var delete: String { localized("Delete", "Hapus") }
    var add: String { localized("Add", "Tambah") }
    var about: String { localized("About", "Tentang") }
}

// MARK: - Tabs

struct TabStrings: StringsBase {
    let language: LanguageOption
    var timer: String { localized("Timer", "Timer") }
    var tasks: String { localized("Tasks", "Tugas") }
    var stats: String { localized("Stats", "Statistik") }
    var settings: String { localized("Settings", "Pengaturan") }

    func title(for tab: AppTab) -> String {
        switch tab {
        case .timer:   timer
        case .tasks:   tasks
        case .stats:   stats
        case .settings: settings
        }
    }
}
