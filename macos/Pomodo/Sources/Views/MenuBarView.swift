//
//  MenuBarView.swift
//  Pomodo (macOS)
//
//  Menu bar extra view - shows timer status in menu bar
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(spacing: 16) {
            // Timer Display
            VStack(spacing: 8) {
                // Session Type
                Text(viewModel.timerState.currentSession.displayName)
                    .font(.headline)
                    .foregroundColor(themeManager.accentColor)

                // Time
                Text(viewModel.timerState.formattedTime)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)

                // Session Progress
                HStack(spacing: 6) {
                    ForEach(0..<viewModel.sessionDots.count, id: \.self) { index in
                        Circle()
                            .fill(viewModel.sessionDots[index] ? themeManager.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.top, 8)

            // Controls
            HStack(spacing: 20) {
                // Reset
                Button(action: { viewModel.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                // Play/Pause
                Button(action: { viewModel.toggleTimer() }) {
                    Image(systemName: viewModel.timerState.status == .running ? "pause.fill" : "play.fill")
                        .font(.title)
                        .frame(width: 56, height: 56)
                        .background(themeManager.accentColor)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)

                // Skip
                Button(action: { viewModel.skipToNextSession() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }

            Divider()

            // Stats
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.red)
                Text("\(viewModel.dailyStats.completedPomodoros) today")
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            Divider()

            // Quick Actions
            VStack(spacing: 4) {
                Button("Open Main Window") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first(where: { $0.title == "Pomodo" || $0.identifier?.rawValue == "main" }) {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)

                Button("Settings...") {
                    viewModel.showSettings = true
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                .keyboardShortcut(",", modifiers: .command)

                Divider()

                Button("Quit Pomodo") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
        .frame(width: 280)
    }
}

#Preview {
    MenuBarView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .frame(width: 280, height: 350)
}
