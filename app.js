// Lo-Fi Study Timer - Main Application Logic

class PomodoroTimer {
    constructor() {
        // Timer settings (in seconds)
        this.settings = {
            workDuration: 25 * 60,
            breakDuration: 5 * 60,
            longBreakDuration: 15 * 60,
            notificationsEnabled: true,
            rainSoundsEnabled: false
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

    initializeElements() {
        // Timer display
        this.timerDisplay = document.getElementById('timerDisplay');
        this.sessionLabel = document.getElementById('sessionLabel');
        this.timerDisplayContainer = document.querySelector('.timer-display');

        // Controls
        this.startBtn = document.getElementById('startBtn');
        this.pauseBtn = document.getElementById('pauseBtn');
        this.resetBtn = document.getElementById('resetBtn');

        // Session dots
        this.sessionDots = document.querySelectorAll('.dot');

        // Settings
        this.settingsToggle = document.getElementById('settingsToggle');
        this.settingsContent = document.getElementById('settingsContent');
        this.workDurationInput = document.getElementById('workDuration');
        this.breakDurationInput = document.getElementById('breakDuration');
        this.longBreakDurationInput = document.getElementById('longBreakDuration');
        this.notificationsToggle = document.getElementById('notificationsToggle');
        this.saveSettingsBtn = document.getElementById('saveSettings');

        // Stats
        this.dailyCountElement = document.getElementById('dailyCount');

        // Sound
        this.notificationSound = document.getElementById('notificationSound');
        this.rainSound = document.getElementById('rainSound');
        this.rainSoundToggle = document.getElementById('rainSoundToggle');

        // Theme
        this.themeToggle = document.getElementById('themeToggle');
        this.themeMenu = document.getElementById('themeMenu');
        this.themeOptions = document.querySelectorAll('.theme-option');

        // Clock
        this.hourHand = document.querySelector('.clock-hand.hour');
        this.minuteHand = document.querySelector('.clock-hand.minute');
    }

    attachEventListeners() {
        this.startBtn.addEventListener('click', () => this.start());
        this.pauseBtn.addEventListener('click', () => this.pause());
        this.resetBtn.addEventListener('click', () => this.reset());

        this.settingsToggle.addEventListener('click', () => this.toggleSettings());
        this.saveSettingsBtn.addEventListener('click', () => this.saveSettings());

        // Rain sound toggle
        this.rainSoundToggle.addEventListener('change', () => this.toggleRainSound());

        // Theme events
        this.themeToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            this.toggleThemeMenu();
        });

        this.themeOptions.forEach(option => {
            option.addEventListener('click', () => {
                const theme = option.dataset.theme;
                this.changeTheme(theme);
            });
        });

        // Close theme menu when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.theme-selector')) {
                this.themeMenu.classList.remove('active');
            }
        });

        // Close settings when clicking outside
        document.addEventListener('click', (e) => {
            if (!e.target.closest('.settings-panel')) {
                this.settingsContent.classList.remove('active');
            }
        });

        // Prevent settings panel from closing when clicking inside
        this.settingsContent.addEventListener('click', (e) => {
            e.stopPropagation();
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            // Ignore if typing in an input field
            if (e.target.tagName === 'INPUT') return;

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

    start() {
        if (!this.isRunning) {
            this.isRunning = true;
            this.startBtn.disabled = true;
            this.pauseBtn.disabled = false;
            this.timerDisplayContainer.classList.add('active');

            this.timerInterval = setInterval(() => {
                this.tick();
            }, 1000);
        }
    }

    pause() {
        if (this.isRunning) {
            this.isRunning = false;
            this.startBtn.disabled = false;
            this.pauseBtn.disabled = true;
            this.timerDisplayContainer.classList.remove('active');
            clearInterval(this.timerInterval);
        }
    }

    reset() {
        this.pause();
        this.timeRemaining = this.isBreak ?
            (this.currentSession === 4 ? this.settings.longBreakDuration : this.settings.breakDuration) :
            this.settings.workDuration;
        this.updateDisplay();
    }

    tick() {
        this.timeRemaining--;

        if (this.timeRemaining < 0) {
            this.completeSession();
        } else {
            this.updateDisplay();
        }
    }

    completeSession() {
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

    updateDisplay() {
        const minutes = Math.floor(this.timeRemaining / 60);
        const seconds = this.timeRemaining % 60;
        this.timerDisplay.textContent =
            `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

        // Update page title
        document.title = `${this.timerDisplay.textContent} - ${this.sessionLabel.textContent} - Pomodo`;
    }

    updateSessionDots() {
        this.sessionDots.forEach((dot, index) => {
            dot.classList.remove('active', 'completed');

            if (index + 1 < this.currentSession) {
                dot.classList.add('completed');
            } else if (index + 1 === this.currentSession && !this.isBreak) {
                dot.classList.add('active');
            }
        });
    }

    resetSessionDots() {
        this.sessionDots.forEach(dot => {
            dot.classList.remove('active', 'completed');
        });
    }

    toggleSettings() {
        this.settingsContent.classList.toggle('active');

        // Load current settings into inputs
        this.workDurationInput.value = this.settings.workDuration / 60;
        this.breakDurationInput.value = this.settings.breakDuration / 60;
        this.longBreakDurationInput.value = this.settings.longBreakDuration / 60;
        this.notificationsToggle.checked = this.settings.notificationsEnabled;
    }

    saveSettings() {
        this.settings.workDuration = parseInt(this.workDurationInput.value) * 60;
        this.settings.breakDuration = parseInt(this.breakDurationInput.value) * 60;
        this.settings.longBreakDuration = parseInt(this.longBreakDurationInput.value) * 60;
        this.settings.notificationsEnabled = this.notificationsToggle.checked;
        this.settings.rainSoundsEnabled = this.rainSoundToggle.checked;

        // Save to localStorage
        localStorage.setItem('pomodoroSettings', JSON.stringify(this.settings));

        // Reset timer with new settings
        this.reset();

        // Close settings panel
        this.settingsContent.classList.remove('active');

        // Show confirmation
        this.showTemporaryMessage('Settings saved!');
    }

    loadSettings() {
        const savedSettings = localStorage.getItem('pomodoroSettings');
        if (savedSettings) {
            this.settings = JSON.parse(savedSettings);
        }

        // Set initial timer value
        this.timeRemaining = this.settings.workDuration;

        // Set initial mode
        document.body.classList.add('work-mode');

        // Apply rain sound setting
        if (this.rainSoundToggle) {
            this.rainSoundToggle.checked = this.settings.rainSoundsEnabled || false;
            if (this.settings.rainSoundsEnabled) {
                this.playRainSound();
            }
        }

        // Load saved theme
        this.loadTheme();
    }

    // Rain sound methods
    toggleRainSound() {
        if (this.rainSoundToggle.checked) {
            this.playRainSound();
        } else {
            this.stopRainSound();
        }
    }

    playRainSound() {
        if (this.rainSound && this.rainSound.src) {
            this.rainSound.volume = 0.3; // Set volume to 30%
            this.rainSound.play().catch(error => {
                console.log('Rain sound playback failed:', error);
                this.showTemporaryMessage('Rain sound file not found. Please add rain-sound.mp3 to your project folder.');
            });
        }
    }

    stopRainSound() {
        if (this.rainSound) {
            this.rainSound.pause();
            this.rainSound.currentTime = 0;
        }
    }

    // Theme methods
    toggleThemeMenu() {
        this.themeMenu.classList.toggle('active');
        this.settingsContent.classList.remove('active');
    }

    changeTheme(theme) {
        // Remove all theme classes
        document.body.classList.remove('theme-night', 'theme-winter', 'theme-spring', 'theme-summer', 'theme-fall');

        // Add new theme class (unless default)
        if (theme !== 'default') {
            document.body.classList.add(`theme-${theme}`);
        }

        // Update active state on buttons
        this.themeOptions.forEach(option => {
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

    loadTheme() {
        const savedTheme = localStorage.getItem('pomodoroTheme') || 'default';

        // Apply theme without showing message on initial load
        document.body.classList.remove('theme-night', 'theme-winter', 'theme-spring', 'theme-summer', 'theme-fall');

        if (savedTheme !== 'default') {
            document.body.classList.add(`theme-${savedTheme}`);
        }

        // Update active state on buttons
        this.themeOptions.forEach(option => {
            option.classList.remove('active');
            if (option.dataset.theme === savedTheme) {
                option.classList.add('active');
            }
        });
    }

    // Clock methods
    startClock() {
        this.updateClock();
        // Update clock every second
        setInterval(() => this.updateClock(), 1000);
    }

    updateClock() {
        const now = new Date();
        const hours = now.getHours() % 12;
        const minutes = now.getMinutes();
        const seconds = now.getSeconds();

        // Calculate rotation angles
        const hourDeg = (hours * 30) + (minutes * 0.5); // 30deg per hour + 0.5deg per minute
        const minuteDeg = (minutes * 6) + (seconds * 0.1); // 6deg per minute + 0.1deg per second

        // Apply rotations
        if (this.hourHand) {
            this.hourHand.style.transform = `rotate(${hourDeg}deg)`;
        }
        if (this.minuteHand) {
            this.minuteHand.style.transform = `rotate(${minuteDeg}deg)`;
        }
    }

    showTemporaryMessage(message) {
        const existingMessage = document.querySelector('.temp-message');
        if (existingMessage) {
            existingMessage.remove();
        }

        const messageEl = document.createElement('div');
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
    requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }

    showNotification(title, body) {
        if (!this.settings.notificationsEnabled) return;

        if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(title, {
                body: body,
                icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="%23fdcb6e"/><text x="50" y="65" font-size="50" text-anchor="middle">🍅</text></svg>',
                badge: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="%23fdcb6e"/></svg>'
            });
        }
    }

    playNotificationSound() {
        if (this.settings.notificationsEnabled) {
            this.notificationSound.play().catch(err => {
                console.log('Could not play notification sound:', err);
            });
        }
    }

    // Statistics methods
    loadDailyStats() {
        const today = new Date().toDateString();
        const statsData = localStorage.getItem('pomodoroStats');

        if (statsData) {
            const stats = JSON.parse(statsData);
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

    updateDailyStats() {
        this.saveDailyStats();
        this.updateDailyStatsDisplay();
    }

    saveDailyStats() {
        const today = new Date().toDateString();
        const stats = {
            date: today,
            count: this.sessionsCompleted
        };
        localStorage.setItem('pomodoroStats', JSON.stringify(stats));
    }

    updateDailyStatsDisplay() {
        this.dailyCountElement.textContent = this.sessionsCompleted;
    }
}

// Add CSS animations for temporary messages
const style = document.createElement('style');
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
    const timer = new PomodoroTimer();
});
