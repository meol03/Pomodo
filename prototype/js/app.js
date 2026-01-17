/**
 * Main Application Logic
 * Connects timer with Spotify integration
 */

// App state
const app = {
  timer: null,
  settings: {
    autoPauseOnBreak: true,
    autoResumeOnWork: true,
    fadeDuration: 3000,
    workDuration: 25,
    breakDuration: 5
  },
  spotify: {
    connected: false,
    currentVolume: 50
  }
};

// DOM Elements
const elements = {
  // Timer
  timerDisplay: document.getElementById('timer-display'),
  sessionType: document.getElementById('session-type'),
  startBtn: document.getElementById('start-btn'),
  pauseBtn: document.getElementById('pause-btn'),
  resetBtn: document.getElementById('reset-btn'),

  // Spotify
  spotifyDisconnected: document.getElementById('spotify-disconnected'),
  spotifyConnected: document.getElementById('spotify-connected'),
  spotifyLoginBtn: document.getElementById('spotify-login-btn'),
  spotifyDisconnectBtn: document.getElementById('spotify-disconnect-btn'),
  nowPlaying: document.getElementById('now-playing'),
  trackName: document.getElementById('track-name'),
  trackArtist: document.getElementById('track-artist'),

  // Settings
  autoPauseBreak: document.getElementById('auto-pause-break'),
  autoResumeWork: document.getElementById('auto-resume-work'),
  fadeDuration: document.getElementById('fade-duration'),
  workDuration: document.getElementById('work-duration'),
  breakDuration: document.getElementById('break-duration')
};

/**
 * Initialize application
 */
async function init() {
  console.log('🍅 Pomodo initializing...');

  // Create timer instance
  app.timer = new PomodoroTimer();

  // Set up timer event handlers
  setupTimerEvents();

  // Set up UI event handlers
  setupUIEvents();

  // Load settings
  loadSettings();

  // Check Spotify connection
  await updateSpotifyUI();

  // Request notification permission
  await app.timer.requestNotificationPermission();

  // Update playback info periodically if connected
  if (app.spotify.connected) {
    setInterval(updateNowPlaying, 5000);
    updateNowPlaying();
  }

  console.log('✓ Pomodo ready!');
}

/**
 * Set up timer event handlers
 */
function setupTimerEvents() {
  // Update display on tick
  app.timer.onTick = (time, sessionType) => {
    elements.timerDisplay.textContent = time;
    elements.sessionType.textContent = sessionType;
    updateDocumentTitle(time, sessionType);
  };

  // Work session starts
  app.timer.onWorkSessionStart = async () => {
    console.log('Work session started');

    if (app.spotify.connected && app.settings.autoResumeOnWork) {
      await SpotifyAPI.resumeAndFadeIn(
        app.spotify.currentVolume,
        app.settings.fadeDuration
      );
    }
  };

  // Work session ends
  app.timer.onWorkSessionEnd = async () => {
    console.log('Work session ended');

    if (app.spotify.connected && app.settings.autoPauseOnBreak) {
      await SpotifyAPI.fadeOutAndPause(app.settings.fadeDuration);
    }
  };

  // Break starts
  app.timer.onBreakStart = () => {
    console.log('Break started');
  };

  // Break ends
  app.timer.onBreakEnd = () => {
    console.log('Break ended');
  };

  // State change (running/paused)
  app.timer.onStateChange = (isRunning, isWorkSession) => {
    elements.startBtn.disabled = isRunning;
    elements.pauseBtn.disabled = !isRunning;
  };
}

/**
 * Set up UI event handlers
 */
function setupUIEvents() {
  // Timer controls
  elements.startBtn.addEventListener('click', () => {
    app.timer.start();
  });

  elements.pauseBtn.addEventListener('click', () => {
    app.timer.pause();
  });

  elements.resetBtn.addEventListener('click', () => {
    app.timer.reset();
  });

  // Spotify controls
  elements.spotifyLoginBtn.addEventListener('click', async () => {
    await SpotifyAuth.login();
  });

  elements.spotifyDisconnectBtn.addEventListener('click', () => {
    SpotifyAuth.logout();
    updateSpotifyUI();
  });

  // Settings
  elements.autoPauseBreak.addEventListener('change', (e) => {
    app.settings.autoPauseOnBreak = e.target.checked;
    saveSettings();
  });

  elements.autoResumeWork.addEventListener('change', (e) => {
    app.settings.autoResumeOnWork = e.target.checked;
    saveSettings();
  });

  elements.fadeDuration.addEventListener('change', (e) => {
    app.settings.fadeDuration = parseInt(e.target.value);
    saveSettings();
  });

  elements.workDuration.addEventListener('change', (e) => {
    const minutes = parseInt(e.target.value);
    app.settings.workDuration = minutes;
    app.timer.setWorkDuration(minutes);
    saveSettings();
  });

  elements.breakDuration.addEventListener('change', (e) => {
    const minutes = parseInt(e.target.value);
    app.settings.breakDuration = minutes;
    app.timer.setBreakDuration(minutes);
    saveSettings();
  });
}

/**
 * Update Spotify UI based on connection status
 */
async function updateSpotifyUI() {
  app.spotify.connected = SpotifyAuth.isLoggedIn();

  if (app.spotify.connected) {
    elements.spotifyDisconnected.style.display = 'none';
    elements.spotifyConnected.style.display = 'block';
  } else {
    elements.spotifyDisconnected.style.display = 'block';
    elements.spotifyConnected.style.display = 'none';
  }
}

/**
 * Update now playing information
 */
async function updateNowPlaying() {
  if (!app.spotify.connected) return;

  const state = await SpotifyAPI.getPlaybackState();

  if (state) {
    app.spotify.currentVolume = state.volumePercent || 50;

    if (state.trackName) {
      elements.trackName.textContent = state.trackName;
      elements.trackArtist.textContent = state.artistName || '';
      elements.nowPlaying.classList.add('playing');
    } else {
      elements.trackName.textContent = 'No track playing';
      elements.trackArtist.textContent = '';
      elements.nowPlaying.classList.remove('playing');
    }
  } else {
    elements.trackName.textContent = 'Not playing';
    elements.trackArtist.textContent = '';
    elements.nowPlaying.classList.remove('playing');
  }
}

/**
 * Update browser tab title with timer
 */
function updateDocumentTitle(time, sessionType) {
  document.title = `${time} - ${sessionType} | Pomodo`;
}

/**
 * Save settings to localStorage
 */
function saveSettings() {
  localStorage.setItem('pomodo_settings', JSON.stringify(app.settings));
  console.log('Settings saved');
}

/**
 * Load settings from localStorage
 */
function loadSettings() {
  const saved = localStorage.getItem('pomodo_settings');

  if (saved) {
    try {
      app.settings = { ...app.settings, ...JSON.parse(saved) };
    } catch (e) {
      console.error('Failed to load settings:', e);
    }
  }

  // Apply settings to UI
  elements.autoPauseBreak.checked = app.settings.autoPauseOnBreak;
  elements.autoResumeWork.checked = app.settings.autoResumeOnWork;
  elements.fadeDuration.value = app.settings.fadeDuration;
  elements.workDuration.value = app.settings.workDuration;
  elements.breakDuration.value = app.settings.breakDuration;

  // Apply to timer
  app.timer.setWorkDuration(app.settings.workDuration);
  app.timer.setBreakDuration(app.settings.breakDuration);

  console.log('Settings loaded');
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', init);
} else {
  init();
}
