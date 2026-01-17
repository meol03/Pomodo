//
//  PomodoApp.swift
//  Pomodo (macOS)
//
//  Main app entry point for macOS
//

import SwiftUI

@main
struct PomodoApp: App {
    @StateObject private var viewModel = PomodoroViewModel()
    @StateObject private var themeManager = ThemeManager()

    // For menu bar mode
    @State private var showMenuBarExtra = true

    var body: some Scene {
        // Main Window
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
                .frame(minWidth: 400, minHeight: 500)
                .frame(maxWidth: 600, maxHeight: 800)
                .onAppear {
                    themeManager.isBreakMode = viewModel.timerState.currentSession != .work
                }
                .onChange(of: viewModel.timerState.currentSession) { _, newSession in
                    themeManager.isBreakMode = newSession != .work
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 450, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) { }

            CommandMenu("Timer") {
                Button(viewModel.timerState.status == .running ? "Pause" : "Start") {
                    viewModel.toggleTimer()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    viewModel.reset()
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()

                Button("Skip to Next Session") {
                    viewModel.skipToNextSession()
                }
                .keyboardShortcut("n", modifiers: .command)
            }

            CommandMenu("Theme") {
                ForEach(AppTheme.allThemes) { theme in
                    Button(theme.name) {
                        themeManager.setTheme(theme)
                    }
                }
            }
        }

        // Menu Bar Extra (optional - shows timer in menu bar)
        MenuBarExtra("Pomodo", systemImage: viewModel.timerState.status == .running ? "leaf.circle.fill" : "leaf.circle") {
            MenuBarView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
        }
        .menuBarExtraStyle(.window)

        // Settings Window
        Settings {
            SettingsWindowView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
        }
    }
}
