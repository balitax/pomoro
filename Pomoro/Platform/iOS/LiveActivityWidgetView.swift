#if os(iOS)
import SwiftUI
import WidgetKit

// MARK: - Live Activity View (used in the Widget Extension for Dynamic Island)

struct PomoroLiveActivityView: View {
    let context: ActivityViewContext<PomoroActivityAttributes>

    var timeRemaining: TimeInterval { context.state.timeRemaining }
    var totalTime: TimeInterval     { context.state.totalTime }
    var isRunning: Bool             { context.state.isRunning }
    var sessionType: String         { context.state.sessionType }

    var progress: Double { context.state.progress }
    var timeString: String { context.state.timeDisplayString }

    // Session color
    var sessionColor: Color {
        switch sessionType {
        case "focus":       Color(red: 1, green: 0.267, blue: 0.267)
        case "short_break": Color(red: 0.204, green: 0.78, blue: 0.349)
        default:            Color(red: 0, green: 0.478, blue: 1)
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(sessionColor.opacity(0.2), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(sessionColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(sessionColor)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(sessionTypeName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(sessionColor)
                Text(timeString)
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            }

            Spacer()

            // State indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(isRunning ? sessionColor : Color.secondary)
                    .frame(width: 6, height: 6)
                Text(isRunning ? "Running" : "Paused")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    var sessionTypeName: String {
        switch sessionType {
        case "focus":       "Focus Session"
        case "short_break": "Short Break"
        default:            "Long Break"
        }
    }
}

// MARK: - Dynamic Island Compact View

struct PomoroDynamicIslandCompactView: View {
    let context: ActivityViewContext<PomoroActivityAttributes>

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
                .font(.system(size: 10, weight: .semibold))
            Text(context.state.timeDisplayString)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .monospacedDigit()
        }
    }
}
#endif
