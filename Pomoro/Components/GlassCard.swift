//
//  GlassCard.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//


import SwiftUI

// MARK: - Glass Card Container

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = PDS.Spacing.md
    var cornerRadius: CGFloat = PDS.Radius.large

    init(
        padding: CGFloat = PDS.Spacing.md,
        cornerRadius: CGFloat = PDS.Radius.large,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - Session Type Badge

struct SessionTypeBadge: View {
    let sessionType: SessionType
    var size: BadgeSize = .regular

    enum BadgeSize {
        case compact, regular, large
        var font: Font {
            switch self {
            case .compact: PDS.Typography.caption2
            case .regular: PDS.Typography.caption
            case .large:   PDS.Typography.footnote
            }
        }
        var padding: EdgeInsets {
            switch self {
            case .compact: EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6)
            case .regular: EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
            case .large:   EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: sessionType.systemImage)
                .font(.system(size: 10, weight: .semibold))
            Text(sessionType.displayName)
                .font(size.font)
                .fontWeight(.semibold)
        }
        .foregroundStyle(sessionType.color)
        .padding(size.padding)
        .background(
            Capsule().fill(sessionType.color.opacity(0.12))
        )
    }
}

// MARK: - Pomoro Logo

struct PomoroLogo: View {
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF2A2A")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: Color(hex: "#FF4444").opacity(0.4), radius: 8, x: 0, y: 4)

            Image(systemName: "timer")
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Progress Ring (Mini)

struct MiniProgressRing: View {
    var progress: Double   // 0...1
    var color: Color
    var size: CGFloat = 28
    var lineWidth: CGFloat = 3

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(PDS.Animation.spring, value: progress)
        }
        .frame(width: size, height: size)
    }
}
