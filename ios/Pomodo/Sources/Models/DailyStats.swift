//
//  DailyStats.swift
//  Pomodo
//
//  Daily statistics tracking
//

import Foundation

struct DailyStats: Codable {
    var date: String
    var completedPomodoros: Int
    var totalFocusMinutes: Int

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static var today: String {
        dateFormatter.string(from: Date())
    }

    static let initial = DailyStats(
        date: today,
        completedPomodoros: 0,
        totalFocusMinutes: 0
    )

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let stats = "pomodoStats"
    }

    // MARK: - Persistence
    static func load() -> DailyStats {
        guard let data = UserDefaults.standard.data(forKey: Keys.stats),
              var stats = try? JSONDecoder().decode(DailyStats.self, from: data) else {
            return .initial
        }

        // Reset if it's a new day
        if stats.date != today {
            stats = .initial
        }

        return stats
    }

    mutating func incrementPomodoro(focusMinutes: Int) {
        self.date = DailyStats.today
        self.completedPomodoros += 1
        self.totalFocusMinutes += focusMinutes
        save()
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Keys.stats)
        }
    }
}
