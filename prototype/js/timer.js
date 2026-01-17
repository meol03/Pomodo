/**
 * Pomodoro Timer Logic
 * Handles work/break sessions with event hooks for Spotify integration
 */

class PomodoroTimer {
  constructor() {
    this.workDuration = 25 * 60; // 25 minutes in seconds
    this.breakDuration = 5 * 60; // 5 minutes in seconds
    this.timeRemaining = this.workDuration;
    this.isRunning = false;
    this.isWorkSession = true;
    this.intervalId = null;

    // Event callbacks
    this.onTick = null;
    this.onWorkSessionStart = null;
    this.onWorkSessionEnd = null;
    this.onBreakStart = null;
    this.onBreakEnd = null;
    this.onStateChange = null;
  }

  /**
   * Set work duration (in minutes)
   */
  setWorkDuration(minutes) {
    this.workDuration = minutes * 60;
    if (this.isWorkSession && !this.isRunning) {
      this.timeRemaining = this.workDuration;
      this._triggerTick();
    }
  }

  /**
   * Set break duration (in minutes)
   */
  setBreakDuration(minutes) {
    this.breakDuration = minutes * 60;
    if (!this.isWorkSession && !this.isRunning) {
      this.timeRemaining = this.breakDuration;
      this._triggerTick();
    }
  }

  /**
   * Start timer
   */
  start() {
    if (this.isRunning) return;

    this.isRunning = true;
    this._triggerStateChange();

    // Trigger session start event
    if (this.isWorkSession && this.onWorkSessionStart) {
      this.onWorkSessionStart();
    } else if (!this.isWorkSession && this.onBreakStart) {
      this.onBreakStart();
    }

    // Start countdown
    this.intervalId = setInterval(() => {
      this.timeRemaining--;
      this._triggerTick();

      if (this.timeRemaining <= 0) {
        this._sessionComplete();
      }
    }, 1000);
  }

  /**
   * Pause timer
   */
  pause() {
    if (!this.isRunning) return;

    this.isRunning = false;
    this._triggerStateChange();

    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  /**
   * Reset timer to current session duration
   */
  reset() {
    this.pause();
    this.timeRemaining = this.isWorkSession ? this.workDuration : this.breakDuration;
    this._triggerTick();
  }

  /**
   * Handle session completion
   */
  async _sessionComplete() {
    this.pause();

    if (this.isWorkSession) {
      // Work session ended, trigger callback
      if (this.onWorkSessionEnd) {
        await this.onWorkSessionEnd();
      }

      // Switch to break
      this.isWorkSession = false;
      this.timeRemaining = this.breakDuration;

      // Play notification sound or show alert
      this._notify('Work session complete! Take a break.');

    } else {
      // Break ended, trigger callback
      if (this.onBreakEnd) {
        await this.onBreakEnd();
      }

      // Switch to work
      this.isWorkSession = true;
      this.timeRemaining = this.workDuration;

      // Play notification sound or show alert
      this._notify('Break complete! Time to focus.');
    }

    this._triggerTick();
    this._triggerStateChange();
  }

  /**
   * Show notification
   */
  _notify(message) {
    // Try browser notification API
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('🍅 Pomodo', {
        body: message,
        icon: 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><text y="75" font-size="75">🍅</text></svg>'
      });
    } else {
      // Fallback to alert
      alert(message);
    }
  }

  /**
   * Request notification permission
   */
  async requestNotificationPermission() {
    if ('Notification' in window && Notification.permission === 'default') {
      await Notification.requestPermission();
    }
  }

  /**
   * Get formatted time string (MM:SS)
   */
  getFormattedTime() {
    const minutes = Math.floor(this.timeRemaining / 60);
    const seconds = this.timeRemaining % 60;
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
  }

  /**
   * Get session type
   */
  getSessionType() {
    return this.isWorkSession ? 'Work Session' : 'Break';
  }

  /**
   * Trigger tick event
   */
  _triggerTick() {
    if (this.onTick) {
      this.onTick(this.getFormattedTime(), this.getSessionType());
    }
  }

  /**
   * Trigger state change event
   */
  _triggerStateChange() {
    if (this.onStateChange) {
      this.onStateChange(this.isRunning, this.isWorkSession);
    }
  }
}
