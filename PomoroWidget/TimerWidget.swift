import WidgetKit
import SwiftUI

// MARK: - Home Screen Widget

struct PomoroTimerWidget: Widget {
    let kind: String = "PomoroTimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerProvider()) { entry in
            TimerWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pomoro Timer")
        .description("See your current focus session at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Lock Screen Widget

struct PomoroLockScreenWidget: Widget {
    let kind: String = "PomoroLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerProvider()) { entry in
            LockScreenWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Pomoro Timer")
        .description("Quick glance at your focus session.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Timeline Provider

struct TimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetTimerEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetTimerEntry) -> Void) {
        completion(WidgetDataStore.shared.load())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetTimerEntry>) -> Void) {
        let entry = WidgetDataStore.shared.load()

        // Refresh every minute
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Home Screen Widget Views

struct TimerWidgetView: View {
    let entry: WidgetTimerEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:  smallView
        case .systemMedium: mediumView
        default:            smallView
        }
    }

    // Small
    private var smallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(sessionColor)
                Spacer()
                Circle()
                    .fill(entry.isRunning ? sessionColor : Color.secondary)
                    .frame(width: 6, height: 6)
            }

            Spacer()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(sessionColor.opacity(0.15), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(sessionColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(entry.timeDisplayString)
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 70, height: 70)
            .frame(maxWidth: .infinity)

            Text(sessionName)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .background(Color(uiColor: .systemBackground))
    }

    // Medium
    private var mediumView: some View {
        HStack(spacing: 16) {
            smallView
                .frame(width: 140)

            VStack(alignment: .leading, spacing: 8) {
                Text("Today")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(entry.completedToday)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(sessionColor)
                    Text("🍅")
                        .font(.system(size: 20))
                }

                Text(entry.completedToday == 1 ? "session" : "sessions")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
    }

    private var sessionColor: Color {
        switch entry.sessionType {
        case "focus":       Color(red: 1, green: 0.267, blue: 0.267)
        case "short_break": Color(red: 0.204, green: 0.78, blue: 0.349)
        case "long_break":  Color(red: 0, green: 0.478, blue: 1)
        default:            Color(red: 1, green: 0.267, blue: 0.267)
        }
    }

    private var sessionName: String {
        switch entry.sessionType {
        case "focus":       "Focus"
        case "short_break": "Short Break"
        case "long_break":  "Long Break"
        default:            "Focus"
        }
    }
}

// MARK: - Lock Screen Widget Views

struct LockScreenWidgetView: View {
    let entry: WidgetTimerEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:  circularView
        case .accessoryRectangular: rectangularView
        case .accessoryInline:    inlineView
        default:                  circularView
        }
    }

    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.system(size: 10, weight: .semibold))
                Text(entry.timeDisplayString)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private var rectangularView: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 1) {
                Text(sessionName)
                    .font(.system(size: 11, weight: .semibold))
                Text(entry.timeDisplayString)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .monospacedDigit()
            }
        }
    }

    private var inlineView: some View {
        Label(entry.timeDisplayString, systemImage: "timer")
            .font(.system(size: 14, design: .rounded))
    }

    private var sessionName: String {
        switch entry.sessionType {
        case "focus":       "Focus"
        case "short_break": "Break"
        case "long_break":  "Long Break"
        default:            "Focus"
        }
    }
}

#if os(iOS)
import UIKit
extension Color {
    init(uiColor: UIColor) { self.init(uiColor) }
}
#endif
