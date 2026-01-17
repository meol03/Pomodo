//
//  ContentView.swift
//  Pomodo (macOS)
//
//  Main content view for macOS
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Background gradient
            themeManager.backgroundGradient
                .ignoresSafeArea()

            // Ambient effects
            AmbientView(type: themeManager.currentTheme.ambientType)
                .opacity(0.6)

            // Main content
            VStack(spacing: 0) {
                // Header
                HeaderView()
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                Spacer()

                // Study Room
                StudyRoomView()
                    .frame(height: 180)
                    .padding(.horizontal, 24)

                Spacer()

                // Timer Display
                TimerView()
                    .padding(.horizontal, 24)

                // Session Dots
                SessionDotsView()
                    .padding(.top, 16)

                Spacer()

                // Controls
                ControlsView()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $viewModel.showThemePicker) {
            ThemePickerView()
                .environmentObject(themeManager)
        }
    }
}

// MARK: - Session Dots
struct SessionDotsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.sessionDots.count, id: \.self) { index in
                Circle()
                    .fill(viewModel.sessionDots[index] ? themeManager.accentColor : themeManager.accentColor.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .frame(width: 450, height: 600)
}
