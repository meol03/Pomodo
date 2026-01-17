//
//  AppSettings.swift
//  Pomodo
//
//  User preferences and settings
//

import Foundation

struct AppSettings: Codable {
    var workDuration: Int
    var shortBreakDuration: Int
    var longBreakDuration: Int
    var sessionsUntilLongBreak: Int
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var selectedTheme: String

    static let `default` = AppSettings(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsUntilLongBreak: 4,
        notificationsEnabled: true,
        soundEnabled: true,
        hapticEnabled: true,
        selectedTheme: "cozy"
    )

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let settings = "pomodoSettings"
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
