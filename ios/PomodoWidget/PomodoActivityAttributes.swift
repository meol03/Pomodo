//
//  PomodoActivityAttributes.swift
//  PomodoWidget
//
//  Data model for Live Activities
//

import ActivityKit
import Foundation

struct PomodoActivityAttributes: ActivityAttributes {
    // Static data - doesn't change during the activity
    let sessionType: String  // "Work", "Short Break", "Long Break"
    let totalDuration: Int   // Total duration in seconds

    // Dynamic data - updates in real-time
    struct ContentState: Codable, Hashable {
        let timeRemaining: Int    // Current time remaining in seconds
        let endTime: Date         // When the timer will complete
        let sessionNumber: Int    // Current session number (1-4)
        let isRunning: Bool       // Whether timer is currently running
    }
}
