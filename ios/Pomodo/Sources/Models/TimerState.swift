//
//  TimerState.swift
//  Pomodo
//
//  Timer state model
//

import Foundation

enum TimerStatus: String, Codable {
    case idle
    case running
    case paused
}

struct TimerState: Codable {
    var timeRemaining: Int
    var status: TimerStatus
    var currentSession: SessionType
    var completedPomodoros: Int
    var sessionsUntilLongBreak: Int
    var endTime: Date?

    static let initial = TimerState(
        timeRemaining: SessionType.work.defaultDuration,
        status: .idle,
        currentSession: .work,
        completedPomodoros: 0,
        sessionsUntilLongBreak: 4,
        endTime: nil
    )

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        let total = currentSession.defaultDuration
        return Double(total - timeRemaining) / Double(total)
    }
}
