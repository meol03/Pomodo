//
//  PomodoLiveActivity.swift
//  PomodoWidget
//
//  Live Activity for Dynamic Island and Lock Screen
//

import ActivityKit
import SwiftUI
import WidgetKit

struct PomodoLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoActivityAttributes.self) { context in
            // Lock Screen / Banner view
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }

                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(context: context)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Compact - Left side
                CompactLeadingView(context: context)
            } compactTrailing: {
                // Compact - Right side (timer countdown)
                CompactTrailingView(context: context)
            } minimal: {
                // Minimal view (when multiple activities)
                MinimalView(context: context)
            }
        }
    }
}

// MARK: - Lock Screen View
struct LockScreenView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var isWorkSession: Bool {
        context.attributes.sessionType == "Work"
    }

    var accentColor: Color {
        isWorkSession ? Color(hex: "#FF6B6B") : Color(hex: "#4CAF50")
    }

    var body: some View {
        HStack(spacing: 16) {
            // Tomato icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: "leaf.circle.fill")
                    .font(.title)
                    .foregroundColor(accentColor)
            }

            // Timer info
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.sessionType)
                    .font(.headline)
                    .foregroundColor(.primary)

                if context.state.isRunning {
                    Text(timerInterval: context.state.endTime...Date(), countsDown: true)
                        .font(.title.monospacedDigit())
                        .foregroundColor(.primary)
                } else {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title.monospacedDigit())
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Session progress dots
            VStack(spacing: 6) {
                Text("Session \(context.state.sessionNumber)/4")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(i < context.state.sessionNumber ? accentColor : accentColor.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }

    func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - Expanded Views
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var isWorkSession: Bool {
        context.attributes.sessionType == "Work"
    }

    var body: some View {
        Image(systemName: "leaf.circle.fill")
            .font(.title2)
            .foregroundColor(isWorkSession ? Color(hex: "#FF6B6B") : Color(hex: "#4CAF50"))
    }
}

struct ExpandedTrailingView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var body: some View {
        if context.state.isRunning {
            Text(timerInterval: context.state.endTime...Date(), countsDown: true)
                .font(.title3.monospacedDigit())
                .foregroundColor(.white)
        } else {
            Image(systemName: "pause.fill")
                .foregroundColor(.orange)
        }
    }
}

struct ExpandedCenterView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var body: some View {
        Text(context.attributes.sessionType)
            .font(.headline)
            .foregroundColor(.white)
    }
}

struct ExpandedBottomView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var isWorkSession: Bool {
        context.attributes.sessionType == "Work"
    }

    var accentColor: Color {
        isWorkSession ? Color(hex: "#FF6B6B") : Color(hex: "#4CAF50")
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(i < context.state.sessionNumber ? accentColor : accentColor.opacity(0.3))
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Compact Views
struct CompactLeadingView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var isWorkSession: Bool {
        context.attributes.sessionType == "Work"
    }

    var body: some View {
        Image(systemName: "leaf.circle.fill")
            .foregroundColor(isWorkSession ? Color(hex: "#FF6B6B") : Color(hex: "#4CAF50"))
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var body: some View {
        if context.state.isRunning {
            Text(timerInterval: context.state.endTime...Date(), countsDown: true)
                .monospacedDigit()
                .frame(width: 50)
                .foregroundColor(.white)
        } else {
            Image(systemName: "pause.fill")
                .foregroundColor(.orange)
        }
    }
}

// MARK: - Minimal View
struct MinimalView: View {
    let context: ActivityViewContext<PomodoActivityAttributes>

    var isWorkSession: Bool {
        context.attributes.sessionType == "Work"
    }

    var body: some View {
        Image(systemName: "leaf.circle.fill")
            .foregroundColor(isWorkSession ? Color(hex: "#FF6B6B") : Color(hex: "#4CAF50"))
    }
}

// MARK: - Color Extension (for Widget)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3:
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Preview
#Preview("Lock Screen", as: .content, using: PomodoActivityAttributes(
    sessionType: "Work",
    totalDuration: 25 * 60
)) {
    PomodoLiveActivity()
} contentStates: {
    PomodoActivityAttributes.ContentState(
        timeRemaining: 1500,
        endTime: Date().addingTimeInterval(1500),
        sessionNumber: 2,
        isRunning: true
    )
}
