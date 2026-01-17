interface TimerSettings {
    workDuration: number;
    breakDuration: number;
    longBreakDuration: number;
    notificationsEnabled: boolean;
}
interface StatsData {
    date: string;
    count: number;
}
type ThemeName = 'default' | 'night' | 'winter' | 'spring' | 'summer' | 'fall';
declare class PomodoroTimer {
    private settings;
    private timeRemaining;
    private timerInterval;
    private isRunning;
    private currentSession;
    private sessionsCompleted;
    private isBreak;
    private timerDisplay;
    private sessionLabel;
    private timerDisplayContainer;
    private startBtn;
    private pauseBtn;
    private resetBtn;
    private sessionDots;
    private settingsToggle;
    private settingsContent;
    private workDurationInput;
    private breakDurationInput;
    private longBreakDurationInput;
    private notificationsToggle;
    private saveSettingsBtn;
    private dailyCountElement;
    private notificationSound;
    private themeToggle;
    private themeMenu;
    private themeOptions;
    constructor();
    private initializeElements;
    private attachEventListeners;
    private start;
    private pause;
    private reset;
    private tick;
    private completeSession;
    private updateDisplay;
    private updateSessionDots;
    private resetSessionDots;
    private toggleSettings;
    private saveSettings;
    private loadSettings;
    private toggleThemeMenu;
    private changeTheme;
    private loadTheme;
    private showTemporaryMessage;
    private requestNotificationPermission;
    private showNotification;
    private playNotificationSound;
    private loadDailyStats;
    private updateDailyStats;
    private saveDailyStats;
    private updateDailyStatsDisplay;
}
declare const style: HTMLStyleElement;
//# sourceMappingURL=app.d.ts.map