//
//  TimerView.swift
//  Pomodo
//
//  Timer display with circular progress and session info
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 24) {
            // Session type label
            Text(viewModel.timerState.currentSession.displayName)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(themeManager.textColor.opacity(0.8))

            // Timer circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        themeManager.accentColor.opacity(0.2),
                        lineWidth: 12
                    )

                // Progress circle
                Circle()
                    .trim(from: 0, to: viewModel.timerState.progress)
                    .stroke(
                        themeManager.accentColor,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.timerState.progress)

                // Time display
                VStack(spacing: 8) {
                    Text(viewModel.timerState.formattedTime)
                        .font(.system(size: 64, weight: .light, design: .monospaced))
                        .foregroundColor(themeManager.textColor)

                    // Status indicator
                    if viewModel.timerState.status == .running {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(themeManager.accentColor)
                                .frame(width: 8, height: 8)
                            Text("Running")
                                .font(.caption)
                                .foregroundColor(themeManager.textColor.opacity(0.6))
                        }
                    } else if viewModel.timerState.status == .paused {
                        Text("Paused")
                            .font(.caption)
                            .foregroundColor(themeManager.textColor.opacity(0.6))
                    }
                }
            }
            .frame(width: 280, height: 280)

            // Session dots
            SessionDotsView()
        }
    }
}

// MARK: - Session Dots
struct SessionDotsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<viewModel.settings.sessionsUntilLongBreak, id: \.self) { index in
                Circle()
                    .fill(
                        viewModel.sessionDots[safe: index] == true
                            ? themeManager.accentColor
                            : themeManager.accentColor.opacity(0.3)
                    )
                    .frame(width: 12, height: 12)
            }
        }
    }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    TimerView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
}
