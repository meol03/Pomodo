//
//  LiveActivityManager.swift
//  Pomodo
//
//  Manages Live Activities for Dynamic Island and Lock Screen
//

import Foundation
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var currentActivity: Activity<PomodoActivityAttributes>?

    private init() {}

    // MARK: - Check Availability
    var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    // MARK: - Start Activity
    func startActivity(sessionType: String, duration: Int, sessionNumber: Int) {
        // End any existing activity first
        endActivity()

        guard areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }

        let attributes = PomodoActivityAttributes(
            sessionType: sessionType,
            totalDuration: duration
        )

        let endTime = Date().addingTimeInterval(TimeInterval(duration))

        let state = PomodoActivityAttributes.ContentState(
            timeRemaining: duration,
            endTime: endTime,
            sessionNumber: sessionNumber,
            isRunning: true
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: endTime.addingTimeInterval(60)),
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }

    // MARK: - Update Activity
    func updateActivity(timeRemaining: Int, isRunning: Bool) {
        guard let activity = currentActivity else { return }

        let endTime = Date().addingTimeInterval(TimeInterval(timeRemaining))

        let state = PomodoActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            endTime: endTime,
            sessionNumber: activity.content.state.sessionNumber,
            isRunning: isRunning
        )

        Task {
            await activity.update(
                ActivityContent(
                    state: state,
                    staleDate: endTime.addingTimeInterval(60)
                )
            )
        }
    }

    // MARK: - End Activity
    func endActivity() {
        guard let activity = currentActivity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("Ended Live Activity: \(activity.id)")
        }

        currentActivity = nil
    }

    // MARK: - End All Activities
    func endAllActivities() {
        Task {
            for activity in Activity<PomodoActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        currentActivity = nil
    }
}
