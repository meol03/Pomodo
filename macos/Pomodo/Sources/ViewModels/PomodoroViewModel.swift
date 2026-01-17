//
//  PomodoroViewModel.swift
//  Pomodo (macOS)
//
//  Main timer view model - handles all timer logic
//

import Foundation
import Combine
import SwiftUI

@MainActor
class PomodoroViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var timerState: TimerState = .initial
    @Published var settings: AppSettings = .default
    @Published var dailyStats: DailyStats = .initial
    @Published var showSettings: Bool = false
    @Published var showThemePicker: Bool = false

    // MARK: - Private Properties
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Managers
    private let notificationManager = NotificationManager.shared

    // MARK: - Initialization
    init() {
        loadData()
        setupNotifications()
    }

    // MARK: - Data Loading
    private func loadData() {
        settings = AppSettings.load()
        dailyStats = DailyStats.load()
        timerState.timeRemaining = settings.workDuration
    }

    private func setupNotifications() {
        Task {
            await notificationManager.requestAuthorization()
        }
    }

    // MARK: - Timer Controls
    func start() {
        guard timerState.status != .running else { return }

        timerState.status = .running
        timerState.endTime = Date().addingTimeInterval(TimeInterval(timerState.timeRemaining))

        // Start the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }

        // Schedule notification
        if settings.notificationsEnabled {
            notificationManager.scheduleTimerCompletion(
                in: TimeInterval(timerState.timeRemaining),
                sessionType: timerState.currentSession
            )
        }
    }

    func pause() {
        guard timerState.status == .running else { return }

        timerState.status = .paused
        timer?.invalidate()
        timer = nil

        // Cancel scheduled notification
        notificationManager.cancelPendingNotifications()
    }

    func reset() {
        timer?.invalidate()
        timer = nil

        timerState.status = .idle
        timerState.timeRemaining = getDurationForCurrentSession()
        timerState.endTime = nil

        // Cancel notifications
        notificationManager.cancelPendingNotifications()
    }

    func toggleTimer() {
        switch timerState.status {
        case .idle, .paused:
            start()
        case .running:
            pause()
        }
    }

    // MARK: - Timer Tick
    private func tick() {
        guard timerState.status == .running else { return }

        if timerState.timeRemaining > 0 {
            timerState.timeRemaining -= 1
        } else {
            completeSession()
        }
    }

    // MARK: - Session Completion
    private func completeSession() {
        timer?.invalidate()
        timer = nil

        // Play sound
        if settings.soundEnabled {
            SoundManager.shared.playCompletionSound()
        }

        // Update stats if work session completed
        if timerState.currentSession == .work {
            timerState.completedPomodoros += 1
            timerState.sessionsUntilLongBreak -= 1
            dailyStats.incrementPomodoro(focusMinutes: settings.workDuration / 60)
        }

        // Determine next session
        moveToNextSession()
    }

    private func moveToNextSession() {
        if timerState.currentSession == .work {
            if timerState.sessionsUntilLongBreak <= 0 {
                timerState.currentSession = .longBreak
                timerState.sessionsUntilLongBreak = settings.sessionsUntilLongBreak
            } else {
                timerState.currentSession = .shortBreak
            }
        } else {
            timerState.currentSession = .work
        }

        timerState.timeRemaining = getDurationForCurrentSession()
        timerState.status = .idle
        timerState.endTime = nil
    }

    private func getDurationForCurrentSession() -> Int {
        switch timerState.currentSession {
        case .work:
            return settings.workDuration
        case .shortBreak:
            return settings.shortBreakDuration
        case .longBreak:
            return settings.longBreakDuration
        }
    }

    // MARK: - Settings
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        settings.save()

        if timerState.status == .idle {
            timerState.timeRemaining = getDurationForCurrentSession()
        }
    }

    func skipToNextSession() {
        reset()
        moveToNextSession()
    }

    // MARK: - Session Dots
    var sessionDots: [Bool] {
        let totalSessions = settings.sessionsUntilLongBreak
        let completed = totalSessions - timerState.sessionsUntilLongBreak
        return (0..<totalSessions).map { $0 < completed }
    }
}
