//
//  SessionType.swift
//  Pomodo
//
//  Pomodoro session types
//

import Foundation

enum SessionType: String, Codable, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    var displayName: String {
        return rawValue
    }

    var defaultDuration: Int {
        switch self {
        case .work:
            return 25 * 60 // 25 minutes
        case .shortBreak:
            return 5 * 60  // 5 minutes
        case .longBreak:
            return 15 * 60 // 15 minutes
        }
    }

    var accentColorName: String {
        switch self {
        case .work:
            return "workAccent"
        case .shortBreak, .longBreak:
            return "breakAccent"
        }
    }
}
