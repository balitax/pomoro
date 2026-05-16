//
//  Strings+Onboarding.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import Foundation

// MARK: - Onboarding

struct OnboardingStrings: StringsBase {
    let language: LanguageOption

    var getStarted: String { localized("Get Started", "Mulai") }

    var page1Title: String { localized("Focus on What Matters", "Fokus pada Hal Penting") }
    var page1Subtitle: String { localized("Use the proven Pomodoro technique to work deeply and recharge intentionally.", "Gunakan teknik Pomodoro untuk bekerja secara mendalam dan istirahat dengan sengaja.") }

    var page2Title: String { localized("Manage Your Tasks", "Kelola Tugas Anda") }
    var page2Subtitle: String { localized("Capture what needs to get done and link tasks directly to your focus sessions.", "Catat apa yang perlu dilakukan dan hubungkan tugas langsung ke sesi fokus Anda.") }

    var page3Title: String { localized("Track Your Progress", "Lacak Kemajuan Anda") }
    var page3Subtitle: String { localized("Daily streaks and insightful charts keep you motivated and on track.", "Rangkaian harian dan grafik informatif membuat Anda tetap termotivasi.") }

    func pageTitle(index: Int) -> String {
        switch index {
        case 0: page1Title
        case 1: page2Title
        case 2: page3Title
        default: ""
        }
    }

    func pageSubtitle(index: Int) -> String {
        switch index {
        case 0: page1Subtitle
        case 1: page2Subtitle
        case 2: page3Subtitle
        default: ""
        }
    }
}

// MARK: - Sign In

struct SignInStrings: StringsBase {
    let language: LanguageOption

    var appName: String { localized("Pomoro", "Pomoro") }
    var tagline: String { localized("Focus beautifully.", "Fokus dengan indah.") }
    var continueWithApple: String { localized("Continue with Apple", "Lanjutkan dengan Apple") }
    var continueWithGoogle: String { localized("Continue with Google", "Lanjutkan dengan Google") }
    var legalPrefix: String { localized("By continuing, you agree to our ", "Dengan melanjutkan, Anda menyetujui ") }
    var termsOfService: String { localized("Terms of Service", "Ketentuan Layanan") }
    var and: String { localized(" and ", " dan ") }
    var privacyPolicy: String { localized("Privacy Policy", "Kebijakan Privasi") }
    var period: String { localized(".", ".") }
}
