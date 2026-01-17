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

### Authorization Code Flow (Recommended)

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

### Option 1: React + Node.js/Express (Full Stack)

**Frontend**: React (or Next.js)
**Backend**: Node.js with Express
**Database**: PostgreSQL or MongoDB (for user settings + tokens)
**Deployment**: Vercel (frontend) + Railway/Render (backend)

**Pros**:
- Clean separation of concerns
- Secure token storage in backend
- Easy to scale
- Good developer experience

**Cons**:
- More complex setup
- Need to deploy both frontend and backend

**Project Structure**:
```
pomodo/
├── client/          (React frontend)
│   ├── src/
│   │   ├── components/
│   │   │   ├── Timer.jsx
│   │   │   ├── SpotifyConnect.jsx
│   │   │   └── MusicSettings.jsx
│   │   ├── services/
│   │   │   └── spotify.js
│   │   └── App.jsx
│   └── package.json
│
├── server/          (Express backend)
│   ├── src/
│   │   ├── routes/
│   │   │   └── spotify.js
│   │   ├── controllers/
│   │   │   └── spotifyController.js
│   │   ├── middleware/
│   │   │   └── auth.js
│   │   └── server.js
│   └── package.json
│
└── README.md
```

### Option 2: Next.js (Full Stack in One)

**Framework**: Next.js (React + API routes)
**Database**: PostgreSQL with Prisma ORM
**Deployment**: Vercel (all-in-one)

**Pros**:
- Single codebase
- API routes built-in (no separate backend)
- Excellent deployment story (Vercel)
- Server-side rendering for better SEO

**Cons**:
- Slightly more opinionated
- API routes run as serverless functions (cold starts)

**Project Structure**:
```
pomodo/
├── app/
│   ├── api/
│   │   └── spotify/
│   │       ├── auth/route.js
│   │       ├── callback/route.js
│   │       └── playback/route.js
│   ├── components/
│   │   ├── Timer.tsx
│   │   ├── SpotifyConnect.tsx
│   │   └── MusicSettings.tsx
│   ├── lib/
│   │   └── spotify.ts
│   └── page.tsx
├── prisma/
│   └── schema.prisma
└── package.json
```

### Option 3: Static Site + Serverless Functions

**Frontend**: Vanilla JS or lightweight framework (Svelte, Solid)
**Backend**: Netlify/Vercel Functions (serverless)
**Database**: Supabase or Firebase

**Pros**:
- Fast and lightweight
- No server to manage
- Free tier very generous
- Simple deployment

**Cons**:
- Serverless cold starts
- More manual state management

### Option 4: Electron (Desktop App)

**Framework**: Electron + React/Vue
**Backend**: Built-in (runs locally)
**Storage**: Local SQLite or files

**Pros**:
- Native desktop experience
- No hosting costs
- Offline timer functionality
- System tray integration

**Cons**:
- Larger download size
- Need to package for multiple OS
- Updates more complex

---

## Recommended Approach for MVP

### Phase 1: Minimum Viable Product

**Tech Stack**: Next.js + Vercel
**Database**: None initially (store tokens in cookies/localStorage for prototype)
**Features**:
- Spotify OAuth login
- Basic timer (25/5 min work/break)
- Auto-pause on break, auto-resume on work
- Simple fade (3 second fixed duration)

**Timeline**: Can be built in a weekend

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
