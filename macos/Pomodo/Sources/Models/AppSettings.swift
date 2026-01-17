//
//  AppSettings.swift
//  Pomodo (macOS)
//
//  User-configurable settings for the timer
//

import Foundation

struct AppSettings: Codable {
    var workDuration: Int          // in seconds
    var shortBreakDuration: Int    // in seconds
    var longBreakDuration: Int     // in seconds
    var sessionsUntilLongBreak: Int
    var soundEnabled: Bool
    var notificationsEnabled: Bool

    static let `default` = AppSettings(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsUntilLongBreak: 4,
        soundEnabled: true,
        notificationsEnabled: true
    )

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let settings = "pomodoroSettings"
    }

    // MARK: - Persistence
    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Keys.settings)
        }
    }
}
