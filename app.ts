// Lo-Fi Study Timer - Main Application Logic

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

class PomodoroTimer {
    // Timer settings
    private settings: TimerSettings;

    // Timer state
    private timeRemaining: number;
    private timerInterval: number | null;
    private isRunning: boolean;
    private currentSession: number;
    private sessionsCompleted: number;
    private isBreak: boolean;

    // DOM elements - Timer display
    private timerDisplay!: HTMLElement;
    private sessionLabel!: HTMLElement;
    private timerDisplayContainer!: HTMLElement;

    // DOM elements - Controls
    private startBtn!: HTMLButtonElement;
    private pauseBtn!: HTMLButtonElement;
    private resetBtn!: HTMLButtonElement;

    // DOM elements - Session dots
    private sessionDots!: NodeListOf<HTMLElement>;

    // DOM elements - Settings
    private settingsToggle!: HTMLButtonElement;
    private settingsContent!: HTMLElement;
    private workDurationInput!: HTMLInputElement;
    private breakDurationInput!: HTMLInputElement;
    private longBreakDurationInput!: HTMLInputElement;
    private notificationsToggle!: HTMLInputElement;
    private saveSettingsBtn!: HTMLButtonElement;

    // DOM elements - Stats
    private dailyCountElement!: HTMLElement;

    // DOM elements - Sound
    private notificationSound!: HTMLAudioElement;

    // DOM elements - Theme
    private themeToggle!: HTMLButtonElement;
    private themeMenu!: HTMLElement;
    private themeOptions!: NodeListOf<HTMLElement>;

    // DOM elements - Clock
    private hourHand!: HTMLElement | null;
    private minuteHand!: HTMLElement | null;

    constructor() {
        // Timer settings (in seconds)
        this.settings = {
            workDuration: 25 * 60,
            breakDuration: 5 * 60,
            longBreakDuration: 15 * 60,
            notificationsEnabled: true
        };

        // Timer state
        this.timeRemaining = this.settings.workDuration;
        this.timerInterval = null;
        this.isRunning = false;
        this.currentSession = 1;
        this.sessionsCompleted = 0;
        this.isBreak = false;

        // Initialize - elements must be initialized first!
        this.initializeElements();
        this.loadSettings();
        this.loadDailyStats();
        this.attachEventListeners();
        this.updateDisplay();
        this.updateSessionDots();
        this.requestNotificationPermission();
        this.startClock();
    }

    private initializeElements(): void {
        // Timer display
        this.timerDisplay = document.getElementById('timerDisplay')!;
        this.sessionLabel = document.getElementById('sessionLabel')!;
        this.timerDisplayContainer = document.querySelector('.timer-display')!;

        // Controls
        this.startBtn = document.getElementById('startBtn') as HTMLButtonElement;
        this.pauseBtn = document.getElementById('pauseBtn') as HTMLButtonElement;
        this.resetBtn = document.getElementById('resetBtn') as HTMLButtonElement;

        // Session dots
        this.sessionDots = document.querySelectorAll('.dot');

        // Settings
        this.settingsToggle = document.getElementById('settingsToggle') as HTMLButtonElement;
        this.settingsContent = document.getElementById('settingsContent')!;
        this.workDurationInput = document.getElementById('workDuration') as HTMLInputElement;
        this.breakDurationInput = document.getElementById('breakDuration') as HTMLInputElement;
        this.longBreakDurationInput = document.getElementById('longBreakDuration') as HTMLInputElement;
        this.notificationsToggle = document.getElementById('notificationsToggle') as HTMLInputElement;
        this.saveSettingsBtn = document.getElementById('saveSettings') as HTMLButtonElement;

        // Stats
        this.dailyCountElement = document.getElementById('dailyCount')!;

        // Sound
        this.notificationSound = document.getElementById('notificationSound') as HTMLAudioElement;

        // Theme
        this.themeToggle = document.getElementById('themeToggle') as HTMLButtonElement;
        this.themeMenu = document.getElementById('themeMenu')!;
        this.themeOptions = document.querySelectorAll('.theme-option');

        // Clock
        this.hourHand = document.querySelector('.clock-hand.hour');
        this.minuteHand = document.querySelector('.clock-hand.minute');
    }

    private attachEventListeners(): void {
        this.startBtn.addEventListener('click', () => this.start());
        this.pauseBtn.addEventListener('click', () => this.pause());
        this.resetBtn.addEventListener('click', () => this.reset());

        this.settingsToggle.addEventListener('click', () => this.toggleSettings());
        this.saveSettingsBtn.addEventListener('click', () => this.saveSettings());

        // Theme events
        this.themeToggle.addEventListener('click', (e: MouseEvent) => {
            e.stopPropagation();
            this.toggleThemeMenu();
        });

        this.themeOptions.forEach((option: HTMLElement) => {
            option.addEventListener('click', () => {
                const theme = option.dataset.theme as ThemeName;
                this.changeTheme(theme);
            });
        });

        // Close theme menu when clicking outside
        document.addEventListener('click', (e: MouseEvent) => {
            const target = e.target as HTMLElement;
            if (!target.closest('.theme-selector')) {
                this.themeMenu.classList.remove('active');
            }
        });

        // Close settings when clicking outside
        document.addEventListener('click', (e: MouseEvent) => {
            const target = e.target as HTMLElement;
            if (!target.closest('.settings-panel')) {
                this.settingsContent.classList.remove('active');
            }
        });

        // Prevent settings panel from closing when clicking inside
        this.settingsContent.addEventListener('click', (e: MouseEvent) => {
            e.stopPropagation();
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e: KeyboardEvent) => {
            // Ignore if typing in an input field
            const target = e.target as HTMLElement;
            if (target.tagName === 'INPUT') return;

            switch(e.key.toLowerCase()) {
                case ' ': // Space - Start/Pause
                    e.preventDefault();
                    if (this.isRunning) {
                        this.pause();
                    } else {
                        this.start();
                    }
                    break;
                case 'r': // R - Reset
                    e.preventDefault();
                    this.reset();
                    break;
                case 's': // S - Settings
                    e.preventDefault();
                    this.toggleSettings();
                    break;
            }
        });
    }

    private start(): void {
        if (!this.isRunning) {
            this.isRunning = true;
            this.startBtn.disabled = true;
            this.pauseBtn.disabled = false;
            this.timerDisplayContainer.classList.add('active');

            this.timerInterval = window.setInterval(() => {
                this.tick();
            }, 1000);
        }
    }

    private pause(): void {
        if (this.isRunning) {
            this.isRunning = false;
            this.startBtn.disabled = false;
            this.pauseBtn.disabled = true;
            this.timerDisplayContainer.classList.remove('active');
            if (this.timerInterval !== null) {
                clearInterval(this.timerInterval);
            }
        }
    }

    private reset(): void {
        this.pause();
        this.timeRemaining = this.isBreak ?
            (this.currentSession === 4 ? this.settings.longBreakDuration : this.settings.breakDuration) :
            this.settings.workDuration;
        this.updateDisplay();
    }

    private tick(): void {
        this.timeRemaining--;

        if (this.timeRemaining < 0) {
            this.completeSession();
        } else {
            this.updateDisplay();
        }
    }

    private completeSession(): void {
        this.pause();
        this.playNotificationSound();

        if (!this.isBreak) {
            // Just completed a work session
            this.sessionsCompleted++;
            this.updateDailyStats();
            this.updateSessionDots();

            if (this.currentSession === 4) {
                // Time for long break
                this.showNotification('Great work!', 'Time for a long break. You earned it!');
                this.isBreak = true;
                this.timeRemaining = this.settings.longBreakDuration;
                this.sessionLabel.textContent = 'Long Break';
                document.body.classList.add('break-mode');
                document.body.classList.remove('work-mode');
            } else {
                // Time for short break
                this.showNotification('Well done!', 'Time for a short break!');
                this.isBreak = true;
                this.timeRemaining = this.settings.breakDuration;
                this.sessionLabel.textContent = 'Short Break';
                document.body.classList.add('break-mode');
                document.body.classList.remove('work-mode');
            }
        } else {
            // Just completed a break
            this.showNotification('Break over!', 'Ready to focus again?');
            this.isBreak = false;
            this.timeRemaining = this.settings.workDuration;
            this.sessionLabel.textContent = 'Focus Time';
            document.body.classList.add('work-mode');
            document.body.classList.remove('break-mode');

            if (this.currentSession === 4) {
                // Reset cycle after long break
                this.currentSession = 1;
                this.resetSessionDots();
            } else {
                this.currentSession++;
            }
            this.updateSessionDots();
        }

        this.updateDisplay();
    }

    private updateDisplay(): void {
        const minutes: number = Math.floor(this.timeRemaining / 60);
        const seconds: number = this.timeRemaining % 60;
        this.timerDisplay.textContent =
            `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

        // Update page title
        document.title = `${this.timerDisplay.textContent} - ${this.sessionLabel.textContent} - Pomodo`;
    }

    private updateSessionDots(): void {
        this.sessionDots.forEach((dot: HTMLElement, index: number) => {
            dot.classList.remove('active', 'completed');

            if (index + 1 < this.currentSession) {
                dot.classList.add('completed');
            } else if (index + 1 === this.currentSession && !this.isBreak) {
                dot.classList.add('active');
            }
        });
    }

    private resetSessionDots(): void {
        this.sessionDots.forEach((dot: HTMLElement) => {
            dot.classList.remove('active', 'completed');
        });
    }

    private toggleSettings(): void {
        this.settingsContent.classList.toggle('active');

        // Load current settings into inputs
        this.workDurationInput.value = String(this.settings.workDuration / 60);
        this.breakDurationInput.value = String(this.settings.breakDuration / 60);
        this.longBreakDurationInput.value = String(this.settings.longBreakDuration / 60);
        this.notificationsToggle.checked = this.settings.notificationsEnabled;
    }

    private saveSettings(): void {
        this.settings.workDuration = parseInt(this.workDurationInput.value, 10) * 60;
        this.settings.breakDuration = parseInt(this.breakDurationInput.value, 10) * 60;
        this.settings.longBreakDuration = parseInt(this.longBreakDurationInput.value, 10) * 60;
        this.settings.notificationsEnabled = this.notificationsToggle.checked;

        // Save to localStorage
        localStorage.setItem('pomodoroSettings', JSON.stringify(this.settings));

        // Reset timer with new settings
        this.reset();

        // Close settings panel
        this.settingsContent.classList.remove('active');

        // Show confirmation
        this.showTemporaryMessage('Settings saved!');
    }

    private loadSettings(): void {
        const savedSettings: string | null = localStorage.getItem('pomodoroSettings');
        if (savedSettings) {
            this.settings = JSON.parse(savedSettings) as TimerSettings;
        }

        // Set initial timer value
        this.timeRemaining = this.settings.workDuration;

        // Set initial mode
        document.body.classList.add('work-mode');

        // Load saved theme
        this.loadTheme();
    }

    // Theme methods
    private toggleThemeMenu(): void {
        this.themeMenu.classList.toggle('active');
        this.settingsContent.classList.remove('active');
    }

    private changeTheme(theme: ThemeName): void {
        // Remove all theme classes
        document.body.classList.remove('theme-night', 'theme-winter', 'theme-spring', 'theme-summer', 'theme-fall');

        // Add new theme class (unless default)
        if (theme !== 'default') {
            document.body.classList.add(`theme-${theme}`);
        }

        // Update active state on buttons
        this.themeOptions.forEach((option: HTMLElement) => {
            option.classList.remove('active');
            if (option.dataset.theme === theme) {
                option.classList.add('active');
            }
        });

        // Save theme to localStorage
        localStorage.setItem('pomodoroTheme', theme);

        // Close theme menu
        this.themeMenu.classList.remove('active');

        // Show confirmation
        this.showTemporaryMessage(`Theme changed to ${theme}!`);
    }

    private loadTheme(): void {
        const savedTheme: string | null = localStorage.getItem('pomodoroTheme');
        const theme: ThemeName = (savedTheme as ThemeName) || 'default';

        // Apply theme without showing message on initial load
        document.body.classList.remove('theme-night', 'theme-winter', 'theme-spring', 'theme-summer', 'theme-fall');

        if (theme !== 'default') {
            document.body.classList.add(`theme-${theme}`);
        }

        // Update active state on buttons
        this.themeOptions.forEach((option: HTMLElement) => {
            option.classList.remove('active');
            if (option.dataset.theme === theme) {
                option.classList.add('active');
            }
        });
    }

    private showTemporaryMessage(message: string): void {
        const existingMessage: HTMLElement | null = document.querySelector('.temp-message');
        if (existingMessage) {
            existingMessage.remove();
        }

        const messageEl: HTMLDivElement = document.createElement('div');
        messageEl.className = 'temp-message';
        messageEl.textContent = message;
        messageEl.style.cssText = `
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: var(--accent);
            color: var(--bg-primary);
            padding: 1rem 2rem;
            border-radius: 30px;
            font-weight: 600;
            z-index: 1000;
            animation: slideDown 0.3s ease;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
        `;

        document.body.appendChild(messageEl);

        setTimeout(() => {
            messageEl.style.animation = 'slideUp 0.3s ease';
            setTimeout(() => messageEl.remove(), 300);
        }, 2000);
    }

    // Notification methods
    private requestNotificationPermission(): void {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }

    private showNotification(title: string, body: string): void {
        if (!this.settings.notificationsEnabled) return;

        if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(title, {
                body: body,
                icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="%23fdcb6e"/><text x="50" y="65" font-size="50" text-anchor="middle">🍅</text></svg>',
                badge: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="%23fdcb6e"/></svg>'
            });
        }
    }

    private playNotificationSound(): void {
        if (this.settings.notificationsEnabled) {
            this.notificationSound.play().catch((err: Error) => {
                console.log('Could not play notification sound:', err);
            });
        }
    }

    // Statistics methods
    private loadDailyStats(): void {
        const today: string = new Date().toDateString();
        const statsData: string | null = localStorage.getItem('pomodoroStats');

        if (statsData) {
            const stats: StatsData = JSON.parse(statsData) as StatsData;
            if (stats.date === today) {
                this.sessionsCompleted = stats.count;
            } else {
                // New day, reset stats
                this.sessionsCompleted = 0;
                this.saveDailyStats();
            }
        }

        this.updateDailyStatsDisplay();
    }

    private updateDailyStats(): void {
        this.saveDailyStats();
        this.updateDailyStatsDisplay();
    }

    private saveDailyStats(): void {
        const today: string = new Date().toDateString();
        const stats: StatsData = {
            date: today,
            count: this.sessionsCompleted
        };
        localStorage.setItem('pomodoroStats', JSON.stringify(stats));
    }

    private updateDailyStatsDisplay(): void {
        this.dailyCountElement.textContent = String(this.sessionsCompleted);
    }

    // Clock methods
    private startClock(): void {
        this.updateClock();
        // Update clock every second
        setInterval(() => this.updateClock(), 1000);
    }

    private updateClock(): void {
        const now: Date = new Date();
        const hours: number = now.getHours() % 12;
        const minutes: number = now.getMinutes();
        const seconds: number = now.getSeconds();

        // Calculate rotation angles
        const hourDeg: number = (hours * 30) + (minutes * 0.5); // 30deg per hour + 0.5deg per minute
        const minuteDeg: number = (minutes * 6) + (seconds * 0.1); // 6deg per minute + 0.1deg per second

        // Apply rotations
        if (this.hourHand) {
            this.hourHand.style.transform = `rotate(${hourDeg}deg)`;
        }
        if (this.minuteHand) {
            this.minuteHand.style.transform = `rotate(${minuteDeg}deg)`;
        }
    }
}

// Add CSS animations for temporary messages
const style: HTMLStyleElement = document.createElement('style');
style.textContent = `
    @keyframes slideDown {
        from {
            opacity: 0;
            transform: translateX(-50%) translateY(-20px);
        }
        to {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
    }

    @keyframes slideUp {
        from {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }
        to {
            opacity: 0;
            transform: translateX(-50%) translateY(-20px);
        }
    }
`;
document.head.appendChild(style);

// Initialize the timer when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new PomodoroTimer();
});
