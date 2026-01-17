//
//  SettingsView.swift
//  Pomodo
//
//  Settings panel for customizing timer durations and preferences
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var workMinutes: Double = 25
    @State private var shortBreakMinutes: Double = 5
    @State private var longBreakMinutes: Double = 15
    @State private var sessionsUntilLongBreak: Double = 4
    @State private var notificationsEnabled: Bool = true
    @State private var soundEnabled: Bool = true
    @State private var hapticEnabled: Bool = true

    var body: some View {
        NavigationView {
            Form {
                // Timer durations
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Work Duration")
                            Spacer()
                            Text("\(Int(workMinutes)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $workMinutes, in: 1...60, step: 1)
                            .tint(themeManager.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Short Break")
                            Spacer()
                            Text("\(Int(shortBreakMinutes)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $shortBreakMinutes, in: 1...30, step: 1)
                            .tint(themeManager.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Long Break")
                            Spacer()
                            Text("\(Int(longBreakMinutes)) min")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $longBreakMinutes, in: 5...60, step: 1)
                            .tint(themeManager.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Sessions Until Long Break")
                            Spacer()
                            Text("\(Int(sessionsUntilLongBreak))")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $sessionsUntilLongBreak, in: 2...8, step: 1)
                            .tint(themeManager.accentColor)
                    }
                } header: {
                    Text("Timer Settings")
                }

                // Notifications & Feedback
                Section {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .tint(themeManager.accentColor)

                    Toggle("Sound", isOn: $soundEnabled)
                        .tint(themeManager.accentColor)

                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                        .tint(themeManager.accentColor)
                } header: {
                    Text("Notifications & Feedback")
                }

                // Statistics
                Section {
                    HStack {
                        Text("Today's Pomodoros")
                        Spacer()
                        Text("\(viewModel.dailyStats.completedPomodoros)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Total Focus Time")
                        Spacer()
                        Text("\(viewModel.dailyStats.totalFocusMinutes) min")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Today's Statistics")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }

    private func loadCurrentSettings() {
        workMinutes = Double(viewModel.settings.workDuration / 60)
        shortBreakMinutes = Double(viewModel.settings.shortBreakDuration / 60)
        longBreakMinutes = Double(viewModel.settings.longBreakDuration / 60)
        sessionsUntilLongBreak = Double(viewModel.settings.sessionsUntilLongBreak)
        notificationsEnabled = viewModel.settings.notificationsEnabled
        soundEnabled = viewModel.settings.soundEnabled
        hapticEnabled = viewModel.settings.hapticEnabled
    }

    private func saveSettings() {
        let newSettings = AppSettings(
            workDuration: Int(workMinutes) * 60,
            shortBreakDuration: Int(shortBreakMinutes) * 60,
            longBreakDuration: Int(longBreakMinutes) * 60,
            sessionsUntilLongBreak: Int(sessionsUntilLongBreak),
            notificationsEnabled: notificationsEnabled,
            soundEnabled: soundEnabled,
            hapticEnabled: hapticEnabled,
            selectedTheme: themeManager.currentTheme.id
        )
        viewModel.updateSettings(newSettings)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
}
