//
//  SettingsView.swift
//  Pomodo (macOS)
//
//  Settings sheet for timer configuration
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    @State private var workMinutes: Double
    @State private var shortBreakMinutes: Double
    @State private var longBreakMinutes: Double
    @State private var sessionsUntilLongBreak: Double
    @State private var soundEnabled: Bool
    @State private var notificationsEnabled: Bool

    init() {
        let settings = AppSettings.load()
        _workMinutes = State(initialValue: Double(settings.workDuration / 60))
        _shortBreakMinutes = State(initialValue: Double(settings.shortBreakDuration / 60))
        _longBreakMinutes = State(initialValue: Double(settings.longBreakDuration / 60))
        _sessionsUntilLongBreak = State(initialValue: Double(settings.sessionsUntilLongBreak))
        _soundEnabled = State(initialValue: settings.soundEnabled)
        _notificationsEnabled = State(initialValue: settings.notificationsEnabled)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    saveSettings()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding()

            Divider()

            // Settings Form
            Form {
                // Timer Durations
                Section("Timer Durations") {
                    DurationSlider(
                        label: "Work",
                        value: $workMinutes,
                        range: 1...60,
                        unit: "min"
                    )

                    DurationSlider(
                        label: "Short Break",
                        value: $shortBreakMinutes,
                        range: 1...30,
                        unit: "min"
                    )

                    DurationSlider(
                        label: "Long Break",
                        value: $longBreakMinutes,
                        range: 1...60,
                        unit: "min"
                    )

                    DurationSlider(
                        label: "Sessions until Long Break",
                        value: $sessionsUntilLongBreak,
                        range: 2...8,
                        unit: "",
                        step: 1
                    )
                }

                // Notifications
                Section("Notifications") {
                    Toggle("Sound", isOn: $soundEnabled)
                    Toggle("Desktop Notifications", isOn: $notificationsEnabled)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)

            Divider()

            // Footer
            HStack {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .foregroundColor(.secondary)

                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])

                Button("Save") {
                    saveSettings()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 400, height: 500)
    }

    private func saveSettings() {
        let settings = AppSettings(
            workDuration: Int(workMinutes) * 60,
            shortBreakDuration: Int(shortBreakMinutes) * 60,
            longBreakDuration: Int(longBreakMinutes) * 60,
            sessionsUntilLongBreak: Int(sessionsUntilLongBreak),
            soundEnabled: soundEnabled,
            notificationsEnabled: notificationsEnabled,
            hapticEnabled: false // Not applicable on macOS
        )
        viewModel.updateSettings(settings)
    }

    private func resetToDefaults() {
        workMinutes = 25
        shortBreakMinutes = 5
        longBreakMinutes = 15
        sessionsUntilLongBreak = 4
        soundEnabled = true
        notificationsEnabled = true
    }
}

// MARK: - Duration Slider
struct DurationSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    var step: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                Spacer()
                Text("\(Int(value))\(unit.isEmpty ? "" : " \(unit)")")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
}
