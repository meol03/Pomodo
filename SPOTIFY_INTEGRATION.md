# Spotify Integration for Pomodo

## Overview

This document outlines the requirements and implementation plan for integrating Spotify playback control into the Pomodo timer application. The integration will allow users to automatically pause/resume their Spotify music during Pomodoro work/break cycles with smooth fade transitions.

## Scope

### What We're Building
- **Simple playback control**: Pause and resume whatever the user is already listening to on Spotify
- **Fade transitions**: Smooth volume fade out before pausing, fade in after resuming
- **User preferences**: Settings to control auto-pause behavior and fade duration
- **Connection status**: Visual indicator showing Spotify connection state

### What We're NOT Building
- Music player UI (play buttons, track selection, etc.)
- Playlist management
- Search functionality
- Music discovery features

**Philosophy**: Control the user's existing Spotify session, don't replace their music app.

---

## Spotify API Requirements

### 1. Developer Account Setup

**Steps to get started:**
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with Spotify account (free)
3. Click "Create an App"
4. Fill in app details:
   - **App Name**: Pomodo (or your choice)
   - **App Description**: Pomodoro timer with Spotify integration
   - **Redirect URI**: `http://localhost:3000/callback` (development) + production URL later
5. Accept Developer Terms of Service
6. Get your **Client ID** and **Client Secret**

**Important Settings:**
- Add all redirect URIs you'll use (localhost for dev, your domain for production)
- Enable "Web API" in API settings

### 2. Required OAuth Scopes

For our use case, we need these permissions:

| Scope | Purpose |
|-------|---------|
| `user-read-playback-state` | Check if music is playing, get current volume |
| `user-modify-playback-state` | Pause, resume, and control volume |

**Note**: We do NOT need `streaming` scope (that's for playing music through our app). We're just controlling existing playback.

### 3. API Endpoints We'll Use

#### Get Current Playback State
```
GET https://api.spotify.com/v1/me/player
```
Returns: Currently playing track, device info, playback state, volume level

#### Pause Playback
```
PUT https://api.spotify.com/v1/me/player/pause
```
Pauses playback on the user's active device

#### Resume Playback
```
PUT https://api.spotify.com/v1/me/player/play
```
Resumes playback on the user's active device

#### Set Volume
```
PUT https://api.spotify.com/v1/me/player/volume?volume_percent={0-100}
```
Sets volume level (0-100)

### 4. Rate Limits

- **Standard rate limit**: Not publicly documented, but generally generous for personal use
- **Best practice**: Cache playback state, don't poll excessively
- **Recommendation**: Check playback state max once per second during active fades

### 5. User Requirements

- **Spotify Premium subscription required** (free tier cannot control playback)
- Active internet connection
- At least one Spotify device active (app, web player, smart speaker, etc.)

---

## Authentication Flow (OAuth 2.0)

Spotify supports two OAuth flows for web applications:

1. **Authorization Code Flow with PKCE** (Recommended for SPAs/No Backend)
2. **Authorization Code Flow** (Requires Backend Server)

### Which Flow Should You Use?

**Use PKCE if:**
- ✅ Building a single-page app (React, Vue, vanilla JS, etc.)
- ✅ Want to avoid backend complexity
- ✅ Don't want to manage server infrastructure
- ✅ Want the simplest possible implementation

**Use Standard Authorization Code Flow if:**
- ✅ Already have a backend server
- ✅ Need to store user data in a database
- ✅ Want centralized token management

**For Pomodo MVP, we recommend PKCE** (no backend needed).

---

### Option 1: Authorization Code Flow with PKCE (No Backend Required!)

PKCE (Proof Key for Code Exchange) is specifically designed for public clients like single-page apps where you can't safely store a client secret.

**Key Advantages:**
- No backend server needed
- No Client Secret required
- Tokens stored in browser (localStorage)
- Simpler deployment (static hosting)
- Works perfectly for Pomodo's use case

#### How PKCE Works

```
┌─────────┐
│  User   │
│ Browser │
└────┬────┘
     │
     │ 1. Generate code_verifier (random string)
     │    Generate code_challenge (SHA256 hash)
     ├────────────────────────────────────┐
     │                                     │
     │<────────────────────────────────────┘
     │
     │ 2. Redirect to Spotify with challenge
     │    (no client secret needed!)
     │
┌────▼────────────────────────────────────┐
│  Spotify Authorization Page             │
│  "Pomodo wants to control your playback"│
│  [Cancel] [Agree]                        │
└────┬────────────────────────────────────┘
     │
     │ 3. User clicks "Agree"
     │
     │ 4. Redirect to callback with code
     │    ?code=AQD...xyz
     ├────────────────────────────────────┐
     │                                     │
     │ 5. Exchange code + code_verifier    │
     │    for access token (in browser!)   │
     │<────────────────────────────────────┘
     │
     │ 6. Store tokens in localStorage
     │
     │ 7. App can now control playback!
     │
```

#### Step-by-Step Implementation

**Step 1: Generate Code Verifier and Challenge**

```javascript
// Generate random code verifier (43-128 characters)
function generateCodeVerifier() {
  const array = new Uint8Array(64);
  crypto.getRandomValues(array);
  return base64URLEncode(array);
}

// Hash the verifier to create challenge
async function generateCodeChallenge(verifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const hash = await crypto.subtle.digest('SHA-256', data);
  return base64URLEncode(new Uint8Array(hash));
}

// Base64 URL encoding helper
function base64URLEncode(buffer) {
  return btoa(String.fromCharCode(...buffer))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
}
```

**Step 2: Redirect to Spotify Authorization**

```javascript
async function redirectToSpotifyAuth() {
  const clientId = 'YOUR_CLIENT_ID'; // Get from Spotify Dashboard
  const redirectUri = 'http://localhost:3000/callback';
  const scope = 'user-read-playback-state user-modify-playback-state';

  // Generate and store verifier
  const codeVerifier = generateCodeVerifier();
  localStorage.setItem('code_verifier', codeVerifier);

  // Generate challenge
  const codeChallenge = await generateCodeChallenge(codeVerifier);

  // Generate random state for CSRF protection
  const state = generateRandomString(16);
  localStorage.setItem('auth_state', state);

  // Build authorization URL
  const params = new URLSearchParams({
    client_id: clientId,
    response_type: 'code',
    redirect_uri: redirectUri,
    scope: scope,
    code_challenge_method: 'S256',
    code_challenge: codeChallenge,
    state: state
  });

  // Redirect user to Spotify
  window.location.href = `https://accounts.spotify.com/authorize?${params}`;
}

function generateRandomString(length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}
```

**Step 3: Handle Callback and Exchange Code for Token**

```javascript
// In your callback page (e.g., /callback)
async function handleCallback() {
  const params = new URLSearchParams(window.location.search);
  const code = params.get('code');
  const state = params.get('state');
  const error = params.get('error');

  // Check for errors
  if (error) {
    console.error('Authorization failed:', error);
    return;
  }

  // Verify state (CSRF protection)
  const storedState = localStorage.getItem('auth_state');
  if (state !== storedState) {
    console.error('State mismatch - possible CSRF attack');
    return;
  }

  // Get code verifier
  const codeVerifier = localStorage.getItem('code_verifier');

  // Exchange code for access token
  const tokenResponse = await fetch('https://accounts.spotify.com/api/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      client_id: 'YOUR_CLIENT_ID',
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: 'http://localhost:3000/callback',
      code_verifier: codeVerifier
    })
  });

  const data = await tokenResponse.json();

  if (data.access_token) {
    // Store tokens
    localStorage.setItem('access_token', data.access_token);
    localStorage.setItem('refresh_token', data.refresh_token);
    localStorage.setItem('expires_at', Date.now() + (data.expires_in * 1000));

    // Clean up
    localStorage.removeItem('code_verifier');
    localStorage.removeItem('auth_state');

    // Redirect to main app
    window.location.href = '/';
  } else {
    console.error('Failed to get access token:', data);
  }
}

// Call this on page load
if (window.location.pathname === '/callback') {
  handleCallback();
}
```

**Step 4: Refresh Token When Expired**

```javascript
async function refreshAccessToken() {
  const refreshToken = localStorage.getItem('refresh_token');

  if (!refreshToken) {
    console.error('No refresh token available');
    return null;
  }

  const response = await fetch('https://accounts.spotify.com/api/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      client_id: 'YOUR_CLIENT_ID',
      grant_type: 'refresh_token',
      refresh_token: refreshToken
    })
  });

  const data = await response.json();

  if (data.access_token) {
    localStorage.setItem('access_token', data.access_token);
    localStorage.setItem('expires_at', Date.now() + (data.expires_in * 1000));

    // Refresh token may be rotated
    if (data.refresh_token) {
      localStorage.setItem('refresh_token', data.refresh_token);
    }

    return data.access_token;
  }

  return null;
}

// Helper to get valid access token
async function getAccessToken() {
  const token = localStorage.getItem('access_token');
  const expiresAt = localStorage.getItem('expires_at');

  // Check if token is expired or about to expire (5 min buffer)
  if (Date.now() >= (parseInt(expiresAt) - 5 * 60 * 1000)) {
    return await refreshAccessToken();
  }

  return token;
}
```

**Step 5: Use Token for API Calls**

```javascript
async function makeSpotifyRequest(endpoint) {
  const token = await getAccessToken();

  if (!token) {
    console.error('No valid access token');
    return null;
  }

  const response = await fetch(`https://api.spotify.com${endpoint}`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  if (response.status === 401) {
    // Token invalid, try refreshing
    const newToken = await refreshAccessToken();
    if (newToken) {
      // Retry request with new token
      return makeSpotifyRequest(endpoint);
    }
  }

  return response;
}
```

#### Complete PKCE Example (Ready to Use)

```html
<!DOCTYPE html>
<html>
<head>
  <title>Pomodo - Spotify PKCE Example</title>
</head>
<body>
  <div id="app">
    <button id="login-btn">Connect Spotify</button>
    <div id="status"></div>
  </div>

  <script>
    const CLIENT_ID = 'YOUR_CLIENT_ID'; // Get from Spotify Dashboard
    const REDIRECT_URI = 'http://localhost:3000/callback.html';
    const SCOPES = 'user-read-playback-state user-modify-playback-state';

    // Base64 URL encode
    function base64URLEncode(buffer) {
      return btoa(String.fromCharCode(...new Uint8Array(buffer)))
        .replace(/\+/g, '-')
        .replace(/\//g, '_')
        .replace(/=+$/, '');
    }

    // Generate code verifier
    function generateCodeVerifier() {
      const array = new Uint8Array(64);
      crypto.getRandomValues(array);
      return base64URLEncode(array);
    }

    // Generate code challenge
    async function generateCodeChallenge(verifier) {
      const data = new TextEncoder().encode(verifier);
      const hash = await crypto.subtle.digest('SHA-256', data);
      return base64URLEncode(hash);
    }

    // Login button click handler
    document.getElementById('login-btn').addEventListener('click', async () => {
      const codeVerifier = generateCodeVerifier();
      const codeChallenge = await generateCodeChallenge(codeVerifier);

      localStorage.setItem('code_verifier', codeVerifier);

      const params = new URLSearchParams({
        client_id: CLIENT_ID,
        response_type: 'code',
        redirect_uri: REDIRECT_URI,
        scope: SCOPES,
        code_challenge_method: 'S256',
        code_challenge: codeChallenge
      });

      window.location.href = `https://accounts.spotify.com/authorize?${params}`;
    });

    // Check if already logged in
    if (localStorage.getItem('access_token')) {
      document.getElementById('status').textContent = 'Connected to Spotify!';
      document.getElementById('login-btn').textContent = 'Disconnect';
    }
  </script>
</body>
</html>
```

**Important Notes for PKCE:**
- ⚠️ **No Client Secret needed** - only Client ID
- ⚠️ **As of November 27, 2025**, Spotify removed support for HTTP redirect URIs - you must use HTTPS in production
- ⚠️ For local development, you can still use `http://localhost` or `http://127.0.0.1`
- ✅ Tokens stored in localStorage (acceptable for SPAs)
- ✅ Perfect for static hosting (Vercel, Netlify, GitHub Pages)

---

### Option 2: Authorization Code Flow (Requires Backend)

This is the standard OAuth 2.0 flow for web apps with a backend.

```
┌─────────┐                                     ┌──────────┐
│  User   │                                     │  Pomodo  │
│ Browser │                                     │  Server  │
└────┬────┘                                     └────┬─────┘
     │                                                │
     │ 1. Click "Connect Spotify"                    │
     ├──────────────────────────────────────────────>│
     │                                                │
     │ 2. Redirect to Spotify authorization          │
     │<───────────────────────────────────────────────┤
     │                                                │
┌────▼────────────────────────────────────────┐     │
│  Spotify Authorization Page                 │     │
│  "Pomodo wants to control your playback"    │     │
│  [Cancel] [Agree]                            │     │
└────┬────────────────────────────────────────┘     │
     │                                                │
     │ 3. User clicks "Agree"                        │
     │                                                │
     │ 4. Redirect to callback with code             │
     ├──────────────────────────────────────────────>│
     │   ?code=AQD...xyz                             │
     │                                                │
     │                                                │ 5. Exchange code
     │                                                │    for tokens
     │                                                ├────────┐
     │                                                │        │
     │                                                │<───────┘
     │                                                │
     │ 6. Store tokens, redirect to app              │
     │<───────────────────────────────────────────────┤
     │                                                │
     │ 7. App can now control playback!              │
     │                                                │
```

### Implementation Steps

#### Step 1: Authorization Request

Redirect user to:
```
https://accounts.spotify.com/authorize?
  client_id=YOUR_CLIENT_ID&
  response_type=code&
  redirect_uri=YOUR_REDIRECT_URI&
  scope=user-read-playback-state user-modify-playback-state&
  state=RANDOM_STRING_FOR_SECURITY
```

#### Step 2: Handle Callback

When Spotify redirects back to your callback URL:
```
https://your-app.com/callback?code=AQD...xyz&state=RANDOM_STRING
```

Verify the `state` matches what you sent (prevents CSRF attacks).

#### Step 3: Exchange Code for Tokens

Make a POST request to:
```
POST https://accounts.spotify.com/api/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic <base64(client_id:client_secret)>

grant_type=authorization_code&
code=AQD...xyz&
redirect_uri=YOUR_REDIRECT_URI
```

Response:
```json
{
  "access_token": "BQD...abc",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "AQA...xyz",
  "scope": "user-read-playback-state user-modify-playback-state"
}
```

#### Step 4: Store Tokens Securely

- **Access token**: Valid for 1 hour, use for API requests
- **Refresh token**: Valid long-term, use to get new access tokens
- Store in secure backend database (NOT localStorage/sessionStorage)

#### Step 5: Use Access Token

Add to API requests:
```
Authorization: Bearer BQD...abc
```

#### Step 6: Refresh Tokens

When access token expires (1 hour), use refresh token:
```
POST https://accounts.spotify.com/api/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic <base64(client_id:client_secret)>

grant_type=refresh_token&
refresh_token=AQA...xyz
```

---

## Playback Control Implementation

### Core Functions

#### 1. Check Playback State

```javascript
async function getPlaybackState(accessToken) {
  const response = await fetch('https://api.spotify.com/v1/me/player', {
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });

  if (response.status === 204) {
    // No active device
    return null;
  }

  const data = await response.json();
  return {
    isPlaying: data.is_playing,
    volumePercent: data.device.volume_percent,
    deviceName: data.device.name,
    trackName: data.item?.name,
    artistName: data.item?.artists[0]?.name
  };
}
```

#### 2. Pause Playback

```javascript
async function pausePlayback(accessToken) {
  await fetch('https://api.spotify.com/v1/me/player/pause', {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });
}
```

#### 3. Resume Playback

```javascript
async function resumePlayback(accessToken) {
  await fetch('https://api.spotify.com/v1/me/player/play', {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });
}
```

#### 4. Set Volume

```javascript
async function setVolume(accessToken, volumePercent) {
  await fetch(`https://api.spotify.com/v1/me/player/volume?volume_percent=${volumePercent}`, {
    method: 'PUT',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    }
  });
}
```

---

## Fade In/Out Feature

### Design Specification

**Goal**: Smoothly transition volume to create a pleasant user experience when pausing/resuming music during Pomodoro cycles.

### Fade Out (Before Break)

```javascript
async function fadeOutAndPause(accessToken, durationMs = 3000) {
  // 1. Get current playback state
  const state = await getPlaybackState(accessToken);

  if (!state || !state.isPlaying) {
    return; // Nothing to fade
  }

  const originalVolume = state.volumePercent;
  const steps = 20; // Number of volume adjustments
  const stepDuration = durationMs / steps;
  const volumeDecrement = originalVolume / steps;

  // 2. Gradually decrease volume
  for (let i = steps; i > 0; i--) {
    const newVolume = Math.round(volumeDecrement * i);
    await setVolume(accessToken, newVolume);
    await sleep(stepDuration);
  }

  // 3. Pause at volume 0
  await pausePlayback(accessToken);

  // 4. Restore original volume (so it's ready for next play)
  await setVolume(accessToken, originalVolume);

  return originalVolume; // Return for later restore
}
```

### Fade In (After Break)

```javascript
async function resumeAndFadeIn(accessToken, targetVolume = 100, durationMs = 3000) {
  // 1. Set volume to 0 before resuming
  await setVolume(accessToken, 0);

  // 2. Resume playback
  await resumePlayback(accessToken);

  // 3. Gradually increase volume
  const steps = 20;
  const stepDuration = durationMs / steps;
  const volumeIncrement = targetVolume / steps;

  for (let i = 1; i <= steps; i++) {
    const newVolume = Math.round(volumeIncrement * i);
    await setVolume(accessToken, newVolume);
    await sleep(stepDuration);
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
```

### User Settings

Allow users to customize fade behavior:

```javascript
const fadeSettings = {
  // Enable/disable auto-pause
  autoPauseOnBreak: true,
  autoResumeAfterBreak: true,

  // Fade duration options
  fadeOutDuration: 3000, // 0, 1000, 2000, 3000, 5000 (ms)
  fadeInDuration: 3000,  // 0, 1000, 2000, 3000, 5000 (ms)

  // Advanced options
  rememberVolume: true, // Remember volume before fade
  pauseImmediatelyOnSkip: false // Skip fade if user manually skips to break
};
```

### Edge Cases to Handle

1. **No active device**: Show notification "No Spotify device found"
2. **Free tier user**: Show error "Spotify Premium required"
3. **Music already paused**: Don't try to pause again
4. **User manually pauses during fade**: Cancel fade, keep paused
5. **User manually resumes during break**: Don't auto-resume later
6. **Network error during fade**: Retry once, then skip to pause/resume
7. **Token expired during fade**: Refresh token, retry operation

---

## Integration with Pomodoro Timer

### Timer Event Hooks

```javascript
class PomodoroTimer {
  constructor(spotifyController) {
    this.spotify = spotifyController;
    this.settings = loadUserSettings();
  }

  async onWorkSessionStart() {
    if (this.settings.spotify.autoResumeAfterBreak) {
      await this.spotify.resumeAndFadeIn(
        this.settings.spotify.fadeInDuration
      );
    }
  }

  async onWorkSessionEnd() {
    // About to start break
    if (this.settings.spotify.autoPauseOnBreak) {
      await this.spotify.fadeOutAndPause(
        this.settings.spotify.fadeOutDuration
      );
    }
  }

  async onBreakStart() {
    // Music already paused in onWorkSessionEnd
    // Could play a notification sound here
  }

  async onBreakEnd() {
    // About to start work session
    // Will resume in onWorkSessionStart
  }
}
```

### UI Components Needed

#### 1. Spotify Connection Button
```
┌─────────────────────────────────┐
│  ♫ Connect Spotify              │  (Disconnected state)
└─────────────────────────────────┘

┌─────────────────────────────────┐
│  ♫ Connected to Spotify         │  (Connected state)
│  Playing: Lofi Hip Hop Radio    │
│  Device: MacBook Pro             │
│  [Disconnect]                    │
└─────────────────────────────────┘
```

#### 2. Music Settings Panel
```
┌─────────────────────────────────┐
│  Music Settings                  │
├─────────────────────────────────┤
│  [✓] Auto-pause during breaks    │
│  [✓] Auto-resume after breaks    │
│                                  │
│  Fade duration:                  │
│  ○ Instant  ○ 1s  ● 3s  ○ 5s    │
│                                  │
│  Current volume: 75%             │
└─────────────────────────────────┘
```

#### 3. Status Indicator
```
Timer display with small indicator:
  25:00  ♫  (Playing)
  05:00  ⏸  (Paused)
  25:00  ♫̶  (Disconnected)
```

---

## Tech Stack Recommendations

Now that we know **PKCE doesn't require a backend**, the simplest approach is much more accessible!

### ⭐ Recommended: Static Site with PKCE (No Backend!)

**Frontend**: Vanilla JS, React, Vue, or Svelte (your choice)
**Authentication**: PKCE (client-side only)
**Storage**: localStorage
**Deployment**: GitHub Pages, Netlify, Vercel (all FREE for static sites)

**Why this is perfect for Pomodo:**
- ✅ Simplest possible setup
- ✅ Zero backend infrastructure
- ✅ Free hosting forever
- ✅ Fast deployment (push to deploy)
- ✅ No server costs or management
- ✅ Perfect for a Pomodoro timer

**What you need:**
```
pomodo/
├── index.html         (Main app)
├── callback.html      (OAuth callback page)
├── js/
│   ├── spotify-auth.js    (PKCE implementation)
│   ├── spotify-api.js     (Playback control)
│   ├── timer.js           (Pomodoro logic)
│   └── fade.js            (Fade in/out)
├── css/
│   └── styles.css
└── README.md
```

**Deployment:**
1. Push to GitHub
2. Enable GitHub Pages
3. Done! Your app is live at `username.github.io/pomodo`

**Cost**: $0/month forever

---

### Option 2: React/Vue SPA with PKCE (Still No Backend!)

**Framework**: React, Vue, or Svelte
**Build Tool**: Vite (fast and modern)
**Authentication**: PKCE (client-side only)
**Deployment**: Vercel or Netlify (free tier)

**Pros**:
- Modern component architecture
- Better state management
- Hot module replacement (dev experience)
- Easy to extend with more features

**Project Structure (React + Vite)**:
```
pomodo/
├── src/
│   ├── components/
│   │   ├── Timer.jsx
│   │   ├── SpotifyConnect.jsx
│   │   ├── MusicSettings.jsx
│   │   └── StatusBar.jsx
│   ├── lib/
│   │   ├── spotify-pkce.js
│   │   ├── spotify-api.js
│   │   └── fade-controller.js
│   ├── App.jsx
│   └── main.jsx
├── public/
│   └── callback.html
├── package.json
└── vite.config.js
```

**Cost**: $0/month

---

### Option 3: Next.js with Backend (If you need user accounts later)

**Framework**: Next.js
**Authentication**: Standard OAuth flow (with backend API routes)
**Database**: PostgreSQL or MongoDB
**Deployment**: Vercel

**Use this if you want:**
- User accounts with saved preferences
- Statistics tracking across devices
- Social features (leaderboards, shared sessions)
- Advanced features requiring server logic

**Pros**:
- Can scale to complex features
- Server-side rendering
- Full-stack in one framework

**Cons**:
- More complex than PKCE approach
- Need database (free tier available)
- Overkill for simple timer

**Cost**: $0-20/month (depending on usage)

---

### Option 4: Electron Desktop App

**Framework**: Electron + React/Vue
**Authentication**: PKCE (no backend needed!)
**Storage**: Local files or SQLite

**Perfect if you want:**
- System tray integration
- Global keyboard shortcuts
- Offline timer functionality
- Native desktop feel

**Pros**:
- Native OS integration
- No hosting needed
- Works offline (timer still functions)
- Desktop notifications

**Cons**:
- Larger download (~100MB)
- Need to package for Windows, Mac, Linux
- Updates require new downloads

**Cost**: $0 (users download and run locally)

---

## Recommended Stack for Pomodo MVP

### 🎯 Absolute Simplest (Weekend Project)

**Stack**: Vanilla HTML/JS + PKCE
**Hosting**: GitHub Pages (free)
**Time to build**: 1-2 days

**Why**: No build tools, no frameworks, just works. Perfect for learning and prototyping.

```html
<!-- index.html - Your entire app! -->
<!DOCTYPE html>
<html>
<head>
  <title>Pomodo - Focus Timer</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <div id="timer">25:00</div>
  <button id="start">Start</button>
  <button id="spotify-connect">Connect Spotify</button>

  <script src="js/spotify-pkce.js"></script>
  <script src="js/timer.js"></script>
  <script src="js/app.js"></script>
</body>
</html>
```

### 🚀 Modern & Scalable (Still Simple)

**Stack**: React + Vite + PKCE
**Hosting**: Vercel (free)
**Time to build**: 2-3 days

**Why**: Better architecture for future features, still no backend needed.

```bash
# Create project
npm create vite@latest pomodo -- --template react
cd pomodo
npm install

# Add Spotify PKCE code (from docs above)
# Build and deploy
npm run build
vercel deploy
```

### 💪 Full-Featured (If You Need Backend)

**Stack**: Next.js + PostgreSQL
**Hosting**: Vercel (free tier generous)
**Time to build**: 1-2 weeks

**Why**: User accounts, saved data, statistics, social features.

**Only choose this if you need**:
- User authentication and profiles
- Synced settings across devices
- Usage statistics and analytics
- Social/collaborative features

---

## My Strong Recommendation

**Start with Option 1 or 2** (PKCE, no backend):

1. **First weekend**: Build vanilla HTML/JS version with PKCE
2. **See if it works for you**: Get feedback, validate the idea
3. **If successful**: Rebuild in React/Vue for better UX
4. **If you need more**: Add backend later (can always upgrade)

**Don't overthink the stack**. The hardest part is getting the Spotify integration right, not choosing between frameworks. Start simple, iterate fast.

### Quick Start Path

```bash
# Option 1: Pure HTML/CSS/JS (recommended to start)
mkdir pomodo
cd pomodo
touch index.html callback.html
mkdir js css
# Copy PKCE code from this doc
# Start coding!

# Option 2: React + Vite (if you prefer React)
npm create vite@latest pomodo -- --template react
cd pomodo
npm install
npm run dev
# Copy PKCE code, build components

# Deploy either one
git init
git add .
git commit -m "Initial commit"
gh repo create pomodo --public --source=. --push
# Enable GitHub Pages or connect to Vercel
```

### Phase 2: Enhanced Version

Add:
- User accounts and settings persistence
- Customizable timer durations
- Adjustable fade durations
- Connection status indicator
- Better error handling

### Phase 3: Polish

Add:
- Multiple timer presets
- Break length variations (short vs long break)
- Statistics tracking
- Keyboard shortcuts
- Dark mode

---

## Security Considerations

### 1. Never Expose Client Secret in Frontend

❌ **Bad**:
```javascript
// In React component - NEVER DO THIS
const clientSecret = 'abc123...';
```

✅ **Good**:
```javascript
// In backend API route only
const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;
```

### 2. Use Environment Variables

```bash
# .env.local (NEVER commit this file)
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/spotify/callback
```

### 3. Validate State Parameter

Prevent CSRF attacks by validating the state parameter:

```javascript
// Before redirect
const state = generateRandomString();
sessionStorage.setItem('spotify_auth_state', state);

// After callback
const storedState = sessionStorage.getItem('spotify_auth_state');
if (state !== storedState) {
  throw new Error('State mismatch - possible CSRF attack');
}
```

### 4. Secure Token Storage

Options ranked by security:

1. **Best**: Backend database with encrypted tokens
2. **Good**: HTTP-only cookies with secure flag
3. **Acceptable for MVP**: localStorage (frontend only, less secure)
4. **Never**: Regular cookies accessible by JavaScript

### 5. Use HTTPS in Production

Spotify requires HTTPS for redirect URIs in production.

---

## Testing Strategy

### Manual Testing Checklist

**OAuth Flow**:
- [ ] Can connect to Spotify
- [ ] Redirects work correctly
- [ ] Tokens are stored and refreshed
- [ ] Can disconnect and reconnect
- [ ] Error handling for denied permissions

**Playback Control**:
- [ ] Pause works when music is playing
- [ ] Resume works when music is paused
- [ ] Volume control works
- [ ] Handles no active device gracefully
- [ ] Works with different Spotify clients (desktop, web, mobile)

**Fade Feature**:
- [ ] Fade out is smooth (no jarring jumps)
- [ ] Fade in is smooth
- [ ] Volume restored correctly after fade
- [ ] Can be disabled in settings
- [ ] Different durations work (instant, 1s, 3s, 5s)

**Timer Integration**:
- [ ] Music pauses at end of work session
- [ ] Music resumes at end of break
- [ ] Manual pause/resume doesn't break automation
- [ ] Settings are respected
- [ ] Works across multiple Pomodoro cycles

**Edge Cases**:
- [ ] Spotify Premium check works
- [ ] Handles expired tokens
- [ ] Network errors don't crash app
- [ ] User manually controlling Spotify doesn't conflict
- [ ] Multiple tabs/windows don't conflict

### Automated Testing

Consider adding:
- Unit tests for fade logic (volume calculations)
- Integration tests for API calls (with mocked responses)
- E2E tests for OAuth flow (with Spotify test account)

---

## Deployment Checklist

### Before Going Live

1. **Spotify App Settings**:
   - [ ] Add production redirect URI
   - [ ] Set app icon and description
   - [ ] Submit for quota extension if needed (default is 25 users)

2. **Environment Variables**:
   - [ ] Set all env vars in production (Vercel/Netlify/etc.)
   - [ ] Never commit secrets to git
   - [ ] Use different credentials for dev vs prod

3. **Security**:
   - [ ] All API routes require authentication
   - [ ] Tokens stored securely
   - [ ] HTTPS enabled
   - [ ] CORS configured correctly

4. **User Experience**:
   - [ ] Clear error messages
   - [ ] Loading states for async operations
   - [ ] Help documentation
   - [ ] Privacy policy (if storing user data)

5. **Monitoring**:
   - [ ] Error tracking (Sentry, LogRocket, etc.)
   - [ ] Analytics (Plausible, PostHog, etc.)
   - [ ] API rate limit monitoring

---

## Future Enhancements

### Possible Features

1. **Multi-Platform Support**:
   - Add Apple Music support
   - Add YouTube Music support
   - Let users choose preferred service

2. **Advanced Music Control**:
   - Lower volume during breaks (instead of pause)
   - Play different playlists for work vs breaks
   - Change tempo/genre based on time of day

3. **Smart Features**:
   - Auto-detect study playlists
   - Suggest optimal music for focus
   - Sync with calendar for automated sessions

4. **Social Features**:
   - Share Pomodoro playlists
   - Compete with friends on focus time
   - Group study sessions with synced music

5. **Integrations**:
   - Slack/Discord status updates
   - Calendar blocking
   - Task management (Todoist, Notion, etc.)

---

## Resources

### Official Documentation
- [Spotify Web API Reference](https://developer.spotify.com/documentation/web-api)
- [Authorization Guide](https://developer.spotify.com/documentation/web-api/concepts/authorization)
- [Scopes](https://developer.spotify.com/documentation/web-api/concepts/scopes)

### Code Examples
- [Spotify Web API Node](https://github.com/thelinmichael/spotify-web-api-node) - Popular Node.js wrapper
- [Authorization Code Flow Example](https://github.com/spotify/web-api-examples/tree/master/authorization_code)

### Community
- [Spotify Developer Community](https://community.spotify.com/t5/Spotify-for-Developers/bd-p/Spotify_Developer)
- Stack Overflow tag: `spotify-web-api`

---

## Questions?

This document should serve as your complete reference for building the Spotify integration. Update it as you learn more during implementation!
