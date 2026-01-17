"use strict";
// Lo-Fi Study Timer - Main Application Logic
class PomodoroTimer {
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
        // Theme
        this.themeToggle = document.getElementById('themeToggle');
        this.themeMenu = document.getElementById('themeMenu');
        this.themeOptions = document.querySelectorAll('.theme-option');
    }
    attachEventListeners() {
        this.startBtn.addEventListener('click', () => this.start());
        this.pauseBtn.addEventListener('click', () => this.pause());
        this.resetBtn.addEventListener('click', () => this.reset());
        this.settingsToggle.addEventListener('click', () => this.toggleSettings());
        this.saveSettingsBtn.addEventListener('click', () => this.saveSettings());
        // Theme events
        this.themeToggle.addEventListener('click', (e) => {
            e.stopPropagation();
            this.toggleThemeMenu();
        });
        this.themeOptions.forEach((option) => {
            option.addEventListener('click', () => {
                const theme = option.dataset.theme;
                this.changeTheme(theme);
            });
        });
        // Close theme menu when clicking outside
        document.addEventListener('click', (e) => {
            const target = e.target;
            if (!target.closest('.theme-selector')) {
                this.themeMenu.classList.remove('active');
            }
        });
        // Close settings when clicking outside
        document.addEventListener('click', (e) => {
            const target = e.target;
            if (!target.closest('.settings-panel')) {
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
            const target = e.target;
            if (target.tagName === 'INPUT')
                return;
            switch (e.key.toLowerCase()) {
                case ' ': // Space - Start/Pause
                    e.preventDefault();
                    if (this.isRunning) {
                        this.pause();
                    }
                    else {
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
            this.timerInterval = window.setInterval(() => {
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
            if (this.timerInterval !== null) {
                clearInterval(this.timerInterval);
            }
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
        }
        else {
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
            }
            else {
                // Time for short break
                this.showNotification('Well done!', 'Time for a short break!');
                this.isBreak = true;
                this.timeRemaining = this.settings.breakDuration;
                this.sessionLabel.textContent = 'Short Break';
                document.body.classList.add('break-mode');
                document.body.classList.remove('work-mode');
            }
        }
        else {
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
            }
            else {
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
            }
            else if (index + 1 === this.currentSession && !this.isBreak) {
                dot.classList.add('active');
            }
        });
    }
    resetSessionDots() {
        this.sessionDots.forEach((dot) => {
            dot.classList.remove('active', 'completed');
        });
    }
    toggleSettings() {
        this.settingsContent.classList.toggle('active');
        // Load current settings into inputs
        this.workDurationInput.value = String(this.settings.workDuration / 60);
        this.breakDurationInput.value = String(this.settings.breakDuration / 60);
        this.longBreakDurationInput.value = String(this.settings.longBreakDuration / 60);
        this.notificationsToggle.checked = this.settings.notificationsEnabled;
    }
    saveSettings() {
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
    loadSettings() {
        const savedSettings = localStorage.getItem('pomodoroSettings');
        if (savedSettings) {
            this.settings = JSON.parse(savedSettings);
        }
        // Set initial timer value
        this.timeRemaining = this.settings.workDuration;
        // Set initial mode
        document.body.classList.add('work-mode');
        // Load saved theme
        this.loadTheme();
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
        this.themeOptions.forEach((option) => {
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
        const savedTheme = localStorage.getItem('pomodoroTheme');
        const theme = savedTheme || 'default';
        this.changeTheme(theme);
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
        if (!this.settings.notificationsEnabled)
            return;
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
            this.notificationSound.play().catch((err) => {
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
            }
            else {
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
        this.dailyCountElement.textContent = String(this.sessionsCompleted);
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
    new PomodoroTimer();
});
//# sourceMappingURL=app.js.map