import WidgetKit
import SwiftUI
import ActivityKit

@main
struct PomoroWidgetBundle: WidgetBundle {
    var body: some Widget {
        PomoroTimerWidget()
        PomoroLockScreenWidget()
        PomoroLiveActivityWidget()
    }
}

// MARK: - Live Activity + Dynamic Island Widget

struct PomoroLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoroActivityAttributes.self) { context in
            PomoroLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ZStack {
                        Circle()
                            .fill(sessionColor(context).opacity(0.12))
                        Circle()
                            .trim(from: 0, to: context.state.progress)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        sessionColor(context).opacity(0.6),
                                        sessionColor(context),
                                        sessionColor(context)
                                    ]),
                                    center: .center,
                                    startAngle: .degrees(-90),
                                    endAngle: .degrees(270)
                                ),
                                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.3), value: context.state.progress)
                        Image("dynamic_icon").resizable().scaledToFit().frame(width: 22, height: 22)
                    }
                    .frame(width: 52, height: 52)
                    .padding(.leading, 6)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(sessionBadge(context))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(sessionColor(context))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(sessionColor(context).opacity(0.15))
                            .clipShape(Capsule())

                        HStack(spacing: 4) {
                            Circle()
                                .fill(context.state.isRunning ? sessionColor(context) : Color.secondary)
                                .frame(width: 5, height: 5)
                            Text(context.state.isRunning ? "Running" : "Paused")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.trailing, 8)
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.timeDisplayString)
                        .font(.system(size: 42, weight: .ultraLight, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image("dynamic_icon").resizable().scaledToFit().frame(width: 12, height: 12)
                            Text(context.state.taskTitle.isEmpty
                                 ? "Pomoro"
                                 : context.state.taskTitle)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(context.state.isRunning
                                 ? "\(elapsedString(context)) elapsed"
                                 : "\(context.state.timeDisplayString) left")
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 20)

                        ProgressView(value: context.state.progress)
                            .tint(sessionColor(context))
                            .background(sessionColor(context).opacity(0.2))
                            .clipShape(Capsule())
                            .padding(.horizontal, 20)
                            .padding(.bottom, 6)
                    }
                }

            } compactLeading: {
                HStack(spacing: 3) {
                    ZStack {
                        Circle()
                            .fill(sessionColor(context).opacity(0.15))
                        Circle()
                            .trim(from: 0, to: context.state.progress)
                            .stroke(sessionColor(context),
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Image("dynamic_icon").resizable().scaledToFit().frame(width: 10, height: 10)
                    }
                    .frame(width: 18, height: 18)
                }
                .padding(.leading, 2)

            } compactTrailing: {
                Text(context.state.timeDisplayString)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .foregroundStyle(sessionColor(context))
                    .padding(.trailing, 4)

            } minimal: {
                Image("dynamic_icon").resizable().scaledToFit().frame(width: 13, height: 13)
            }
        }
    }

    private func elapsedString(_ ctx: ActivityViewContext<PomoroActivityAttributes>) -> String {
        let elapsed = ctx.state.totalTime - ctx.state.timeRemaining
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func sessionColor(_ ctx: ActivityViewContext<PomoroActivityAttributes>) -> Color {
        switch ctx.state.sessionType {
        case "focus":       Color(red: 1,     green: 0.267, blue: 0.267)
        case "short_break": Color(red: 0.204, green: 0.78,  blue: 0.349)
        default:            Color(red: 0,     green: 0.478, blue: 1)
        }
    }

    private func sessionBadge(_ ctx: ActivityViewContext<PomoroActivityAttributes>) -> String {
        switch ctx.state.sessionType {
        case "focus":       "Focus"
        case "short_break": "Short Break"
        default:            "Long Break"
        }
    }
}
