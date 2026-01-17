//
//  PomodoApp.swift
//  Pomodo
//
//  Main app entry point
//

import SwiftUI

@main
struct PomodoApp: App {
    @StateObject private var viewModel = PomodoroViewModel()
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
                .environment(\.theme, themeManager.currentTheme)
                .preferredColorScheme(.dark)
                .onReceive(viewModel.$timerState) { state in
                    // Update theme manager's break mode
                    themeManager.isBreakMode = state.currentSession != .work
                }
        }
    }
}
