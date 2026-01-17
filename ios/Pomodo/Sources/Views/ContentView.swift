//
//  ContentView.swift
//  Pomodo
//
//  Main content view - the primary app interface
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Background
            themeManager.backgroundGradient
                .ignoresSafeArea()

            // Ambient animation layer
            AmbientView(type: themeManager.currentTheme.ambientType)

            // Main content
            VStack(spacing: 0) {
                // Header
                HeaderView()
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                // Study room illustration
                StudyRoomView()
                    .frame(height: 200)
                    .padding(.horizontal)

                Spacer()

                // Timer display
                TimerView()
                    .padding(.horizontal)

                Spacer()

                // Controls
                ControlsView()
                    .padding(.horizontal)
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .environmentObject(viewModel)
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $viewModel.showThemePicker) {
            ThemePickerView()
                .environmentObject(themeManager)
                .presentationDetents([.medium])
        }
        .animation(.easeInOut(duration: 0.5), value: themeManager.isBreakMode)
        .animation(.easeInOut(duration: 0.5), value: themeManager.currentTheme.id)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
}
