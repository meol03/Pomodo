//
//  SessionType.swift
//  Pomodo (macOS)
//
//  Defines the types of timer sessions
//

import Foundation

enum SessionType: String, Codable {
    case work
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .work:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }

    var shortName: String {
        switch self {
        case .work:
            return "Work"
        case .shortBreak:
            return "Break"
        case .longBreak:
            return "Long Break"
        }
    }
}
