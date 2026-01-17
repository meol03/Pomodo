//
//  SettingsWindowView.swift
//  Pomodo (macOS)
//
//  Native macOS Settings window (⌘,)
//

import SwiftUI

struct SettingsWindowView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            // Timer Tab
            TimerSettingsTab()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Timer", systemImage: "clock")
                }

            // Appearance Tab
            AppearanceSettingsTab()
                .environmentObject(themeManager)
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }

            // Notifications Tab
            NotificationSettingsTab()
                .environmentObject(viewModel)
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }

            // About Tab
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

// MARK: - Timer Settings Tab
struct TimerSettingsTab: View {
    @EnvironmentObject var viewModel: PomodoroViewModel

    @AppStorage("workDuration") private var workMinutes: Int = 25
    @AppStorage("shortBreakDuration") private var shortBreakMinutes: Int = 5
    @AppStorage("longBreakDuration") private var longBreakMinutes: Int = 15
    @AppStorage("sessionsUntilLongBreak") private var sessions: Int = 4

    var body: some View {
        Form {
            Section {
                Stepper("Work Duration: \(workMinutes) min", value: $workMinutes, in: 1...60)
                Stepper("Short Break: \(shortBreakMinutes) min", value: $shortBreakMinutes, in: 1...30)
                Stepper("Long Break: \(longBreakMinutes) min", value: $longBreakMinutes, in: 1...60)
                Stepper("Sessions until Long Break: \(sessions)", value: $sessions, in: 2...8)
            }

            Section {
                Button("Apply Changes") {
                    let settings = AppSettings(
                        workDuration: workMinutes * 60,
                        shortBreakDuration: shortBreakMinutes * 60,
                        longBreakDuration: longBreakMinutes * 60,
                        sessionsUntilLongBreak: sessions,
                        soundEnabled: viewModel.settings.soundEnabled,
                        notificationsEnabled: viewModel.settings.notificationsEnabled,
                        hapticEnabled: false
                    )
                    viewModel.updateSettings(settings)
                }

                Button("Reset to Defaults") {
                    workMinutes = 25
                    shortBreakMinutes = 5
                    longBreakMinutes = 15
                    sessions = 4
                }
                .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Appearance Settings Tab
struct AppearanceSettingsTab: View {
    @EnvironmentObject var themeManager: ThemeManager

    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AppTheme.allThemes) { theme in
                    ThemePreviewCard(
                        theme: theme,
                        isSelected: theme.id == themeManager.currentTheme.id
                    ) {
                        themeManager.setTheme(theme)
                    }
                }
            }
            .padding()
        }
    }
}

struct ThemePreviewCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    LinearGradient(
                        colors: [theme.workBackgroundPrimary, theme.workBackgroundSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: theme.icon)
                        .font(.title)
                        .foregroundColor(theme.workAccent)
                }
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? theme.workAccent : Color.clear, lineWidth: 2)
                )

                Text(theme.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? theme.workAccent : .secondary)
            }
            .scaleEffect(isHovered ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Notification Settings Tab
struct NotificationSettingsTab: View {
    @EnvironmentObject var viewModel: PomodoroViewModel

    @State private var soundEnabled: Bool = true
    @State private var notificationsEnabled: Bool = true

    var body: some View {
        Form {
            Section {
                Toggle("Play Sound on Completion", isOn: $soundEnabled)
                    .onChange(of: soundEnabled) { _, newValue in
                        updateSettings(sound: newValue)
                    }

                Toggle("Show Desktop Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        updateSettings(notifications: newValue)
                    }
            }

            Section {
                Button("Request Notification Permission") {
                    Task {
                        await NotificationManager.shared.requestAuthorization()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            soundEnabled = viewModel.settings.soundEnabled
            notificationsEnabled = viewModel.settings.notificationsEnabled
        }
    }

    private func updateSettings(sound: Bool? = nil, notifications: Bool? = nil) {
        var settings = viewModel.settings
        if let sound = sound { settings.soundEnabled = sound }
        if let notifications = notifications { settings.notificationsEnabled = notifications }
        viewModel.updateSettings(settings)
    }
}

// MARK: - About Tab
struct AboutTab: View {
    var body: some View {
        VStack(spacing: 16) {
            // App Icon
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red, .green)

            // App Name
            Text("Pomodo")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0")
                .foregroundColor(.secondary)

            Text("A beautiful Pomodoro timer for focused work sessions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Spacer()

            // Links
            HStack(spacing: 20) {
                Link("Website", destination: URL(string: "https://github.com")!)
                Link("Support", destination: URL(string: "https://github.com")!)
            }
            .font(.caption)
        }
        .padding()
    }
}

#Preview {
    SettingsWindowView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
}
