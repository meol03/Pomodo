//
//  TimerView.swift
//  Pomodo (macOS)
//
//  Timer display with session type indicator
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 12) {
            // Session Type Label
            Text(viewModel.timerState.currentSession.displayName.uppercased())
                .font(.subheadline)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundColor(themeManager.accentColor)

            // Timer Display
            Text(viewModel.timerState.formattedTime)
                .font(.system(size: 72, weight: .light, design: .monospaced))
                .foregroundColor(themeManager.textColor)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: viewModel.timerState.timeRemaining)

            // Status indicator
            if viewModel.timerState.status == .running {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Running")
                        .font(.caption)
                        .foregroundColor(themeManager.textColor.opacity(0.7))
                }
            } else if viewModel.timerState.status == .paused {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                    Text("Paused")
                        .font(.caption)
                        .foregroundColor(themeManager.textColor.opacity(0.7))
                }
            }
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
}
