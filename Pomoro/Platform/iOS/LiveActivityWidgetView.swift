//
//  LiveActivityWidgetView.swift
//  Pomoro
//
//  Author: Agus Cahyono
//  Created: 2025-05-16 17:00
//  LinkedIn: https://linkedin.com/in/cahyocode
//  Email: cahyo.mamen@gmail.com
//

import SwiftUI
import WidgetKit
import ActivityKit

struct PomoroLiveActivityView: View {
    let context: ActivityViewContext<PomoroActivityAttributes>
    @Environment(Language.self) private var language

    private var progress: Double    { context.state.progress }
    private var timeString: String  { context.state.timeDisplayString }
    private var isRunning: Bool     { context.state.isRunning }
    private var sessionType: String { context.state.sessionType }

    private var sessionColor: Color {
        switch sessionType {
        case "focus":       Color(red: 1,     green: 0.267, blue: 0.267)
        case "short_break": Color(red: 0.204, green: 0.78,  blue: 0.349)
        default:            Color(red: 0,     green: 0.478, blue: 1)
        }
    }

    private var sessionGradient: LinearGradient {
        switch sessionType {
        case "focus":
            LinearGradient(colors: [Color(hex: "#FF6B6B"), Color(hex: "#FF4444")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case "short_break":
            LinearGradient(colors: [Color(hex: "#4CD964"), Color(hex: "#30C85A")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            LinearGradient(colors: [Color(hex: "#5AC8FA"), Color(hex: "#007AFF")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var sessionName: String {
        Language.shared.liveActivity.sessionName(for: sessionType)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(sessionColor.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(sessionGradient,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.3), value: progress)
                ZStack {
                    Circle()
                        .fill(sessionColor.opacity(0.1))
                        .frame(width: 28, height: 28)
                    Image("dynamic_icon").resizable().scaledToFit().frame(width: 16, height: 16)
                }
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(sessionName)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(sessionColor)
                    if !context.state.taskTitle.isEmpty {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text(context.state.taskTitle)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Text(timeString)
                    .font(.system(size: 28, weight: .ultraLight, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                HStack(spacing: 4) {
                    ProgressView(value: progress)
                        .tint(sessionColor)
                        .frame(width: 80)
                    Text(language.liveActivity.statusLabel(isRunning: isRunning))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            VStack(spacing: 6) {
                Image("dynamic_icon").resizable().scaledToFit().frame(width: 18, height: 18)
                    .opacity(0.5)
                HStack(spacing: 3) {
                    Circle()
                        .fill(isRunning ? sessionColor : Color.secondary)
                        .frame(width: 5, height: 5)
                    Text(language.liveActivity.statusLabel(isRunning: isRunning))
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(sessionColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
