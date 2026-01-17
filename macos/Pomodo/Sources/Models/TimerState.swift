//
//  TimerState.swift
//  Pomodo (macOS)
//
//  Represents the current state of the timer
//

import Foundation

enum TimerStatus {
    case idle
    case running
    case paused
}

struct TimerState {
    var status: TimerStatus = .idle
    var timeRemaining: Int = 25 * 60  // in seconds
    var currentSession: SessionType = .work
    var completedPomodoros: Int = 0
    var sessionsUntilLongBreak: Int = 4
    var endTime: Date?

    static let initial = TimerState()

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard let endTime = endTime else { return 0 }
        let totalDuration = endTime.timeIntervalSinceNow + Double(timeRemaining)
        guard totalDuration > 0 else { return 0 }
        return 1 - (Double(timeRemaining) / totalDuration)
    }
}
