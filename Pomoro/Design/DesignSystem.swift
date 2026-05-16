//
//  DesignSystem.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

// MARK: - Pomoro Design System

/// Central design system for consistent UI across iOS and macOS
enum PDS {

    // MARK: - Colors

    enum Colors {
        // Session States
        static let focusRed      = Color(hex: "#FF4444")
        static let breakGreen    = Color(hex: "#34C759")
        static let longBreakBlue = Color(hex: "#007AFF")

        // Backgrounds
        static let background      = Color(hex: "#0E0E0F")
        static let surface         = Color(hex: "#1C1C1E")
        static let surfaceElevated = Color(hex: "#2C2C2E")

        // Text
        static let label           = Color.primary
        static let secondaryLabel  = Color.secondary
        static let tertiaryLabel   = Color(hex: "#636366")

        // System
        static let separator = Color(hex: "#38383A")
        static let accent    = Color(hex: "#FF4444")
    }

    // MARK: - Radius

    enum Radius {
        static let small:   CGFloat = 8
        static let medium:  CGFloat = 14
        static let large:   CGFloat = 20
        static let xlarge:  CGFloat = 28
        static let circle:  CGFloat = 999
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 16
        static let lg:  CGFloat = 24
        static let xl:  CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Typography

    enum Typography {
        static func timerDisplay(_ size: CGFloat = 72) -> Font {
            .system(size: size, weight: .thin, design: .rounded)
        }
        static let heroTitle   = Font.system(size: 34, weight: .bold,   design: .rounded)
        static let title1      = Font.system(size: 28, weight: .bold,   design: .rounded)
        static let title2      = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3      = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let headline    = Font.system(size: 17, weight: .semibold, design: .default)
        static let body        = Font.system(size: 17, weight: .regular, design: .default)
        static let callout     = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote    = Font.system(size: 13, weight: .regular, design: .default)
        static let caption     = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2    = Font.system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Shadows

    enum Shadow {
        static let soft   = ShadowStyle(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
        static let medium = ShadowStyle(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 8)
        static let glow   = ShadowStyle(color: PDS.Colors.focusRed.opacity(0.4), radius: 30, x: 0, y: 0)
    }

    // MARK: - Animation

    enum Animation {
        static let spring       = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
        static let snappy       = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let bouncy       = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.65)
        static let smooth       = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let fast         = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let timerRing    = SwiftUI.Animation.linear(duration: 1.0)
    }

    // MARK: - Ring

    enum Ring {
        static let lineWidth:   CGFloat = 10
        static let size:        CGFloat = 280
        static let backgroundOpacity: Double = 0.12
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Session Color

extension SessionType {
    var color: Color {
        switch self {
        case .focus:      PDS.Colors.focusRed
        case .shortBreak: PDS.Colors.breakGreen
        case .longBreak:  PDS.Colors.longBreakBlue
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .focus:
            [Color(hex: "#FF6B6B"), Color(hex: "#FF4444")]
        case .shortBreak:
            [Color(hex: "#4CD964"), Color(hex: "#30C85A")]
        case .longBreak:
            [Color(hex: "#5AC8FA"), Color(hex: "#007AFF")]
        }
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { $0.opacity(0.15) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

}

// MARK: - View Modifiers

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = PDS.Radius.large
    var opacity: Double = 0.08

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                    )
            )
    }
}

struct CardBackground: ViewModifier {
    var cornerRadius: CGFloat = PDS.Radius.large

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.platformSecondaryBackground)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
            )
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = PDS.Radius.large) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }

    func cardBackground(cornerRadius: CGFloat = PDS.Radius.large) -> some View {
        modifier(CardBackground(cornerRadius: cornerRadius))
    }

    func pShadow(_ style: ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Platform Color Helpers

extension Color {
    static var platformSecondaryBackground: Color {
        #if os(iOS)
        Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color.gray.opacity(0.1)
        #endif
    }

    static var platformBackground: Color {
        #if os(iOS)
        Color(UIColor.systemBackground)
        #elseif os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color.black
        #endif
    }
}
