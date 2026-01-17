//
//  ControlsView.swift
//  Pomodo
//
//  Timer control buttons
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 24) {
            // Reset button
            Button {
                viewModel.reset()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(themeManager.textColor.opacity(0.7))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.15))
                    )
            }

            // Main play/pause button
            Button {
                viewModel.toggleTimer()
            } label: {
                Image(systemName: viewModel.timerState.status == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundColor(themeManager.backgroundColor)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(themeManager.accentColor)
                    )
                    .shadow(color: themeManager.accentColor.opacity(0.4), radius: 10, y: 4)
            }
            .scaleEffect(viewModel.timerState.status == .running ? 1.0 : 1.05)
            .animation(.spring(response: 0.3), value: viewModel.timerState.status)

            // Skip button
            Button {
                viewModel.skipToNextSession()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(themeManager.textColor.opacity(0.7))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(themeManager.accentColor.opacity(0.15))
                    )
            }
        }
    }
}

#Preview {
    ControlsView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
}
