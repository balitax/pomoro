//
//  Strings+Timer.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Timer

struct TimerStrings: StringsBase {
    let language: LanguageOption

    var upNext: String { localized("Up Next", "Selanjutnya") }
    var linkATask: String { localized("Link a task", "Hubungkan tugas") }
    var chooseTask: String { localized("Choose Task", "Pilih Tugas") }
    var noTasks: String { localized("No Tasks", "Tidak Ada Tugas") }
    var addTaskToLink: String { localized("Add a task to link it to your session", "Tambahkan tugas untuk menghubungkannya ke sesi Anda") }
    var separator: String { localized("·", "·") }
    var sesi: String { localized("session", "sesi") }

    func sessionLabel(_ name: String) -> String {
        language == .english ? "\(name) session" : "Sesi \(name)"
    }

    func sessionsProgress(current: Int, total: Int) -> String {
        language == .english ? "\(current) of \(total)" : "\(current) dari \(total)"
    }

    func taskProgress(completed: Int, estimated: Int) -> String {
        language == .english ? "\(completed) / \(estimated) sessions" : "\(completed) / \(estimated) sesi"
    }

    func pomodorosRemaining(_ count: Int) -> String {
        language == .english ? "\(count) pomodoros remaining" : "\(count) pomodoro tersisa"
    }
}

// MARK: - Info

struct InfoStrings: StringsBase {
    let language: LanguageOption

    var title: String { localized("About Pomoro", "Tentang Pomoro") }
    var appName: String { localized("Pomoro", "Pomoro") }
    var versionLabel: String { localized("Version 1.0", "Versi 1.0") }
    var pomodoroTimer: String { localized("Pomodoro Timer", "Pengatur Waktu Pomodoro") }
    var pomodoroTimerDesc: String { localized("Focus sessions with short and long breaks", "Sesi fokus dengan istirahat singkat dan panjang") }
    var taskTracking: String { localized("Task Tracking", "Pelacakan Tugas") }
    var taskTrackingDesc: String { localized("Link tasks to your focus sessions", "Hubungkan tugas ke sesi fokus Anda") }
    var statistics: String { localized("Statistics", "Statistik") }
    var statisticsDesc: String { localized("Track your productivity over time", "Lacak produktivitas Anda dari waktu ke waktu") }
    var notifications: String { localized("Notifications", "Notifikasi") }
    var notificationsDesc: String { localized("Get notified when your session ends", "Dapatkan notifikasi saat sesi Anda berakhir") }
    var iOSMacOS: String { localized("iOS & macOS", "iOS & macOS") }
    var iOSMacOSDesc: String { localized("Available on all your Apple devices", "Tersedia di semua perangkat Apple Anda") }
    var madeWithLove: String { localized("Made with ♥ by Agus Cahyono", "Dibuat dengan ♥ oleh Agus Cahyono") }
    var copyright: String { localized("© 2025 Pomoro. All rights reserved.", "© 2025 Pomoro. Hak cipta dilindungi.") }

    struct FeatureRow {
        let icon: String
        let title: String
        let subtitle: String
    }

    var featureRows: [FeatureRow] {
        [
            FeatureRow(icon: "timer", title: pomodoroTimer, subtitle: pomodoroTimerDesc),
            FeatureRow(icon: "checklist", title: taskTracking, subtitle: taskTrackingDesc),
            FeatureRow(icon: "chart.bar.fill", title: statistics, subtitle: statisticsDesc),
            FeatureRow(icon: "bell.badge", title: notifications, subtitle: notificationsDesc),
            FeatureRow(icon: "macbook.and.iphone", title: iOSMacOS, subtitle: iOSMacOSDesc),
        ]
    }
}
