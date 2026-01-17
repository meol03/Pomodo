# 🍅 Pomodo - Proof of Concept

A Pomodoro timer with Spotify integration featuring automatic music pause/resume with smooth fade transitions.

## Features

- ⏱️ **Pomodoro Timer**: 25-minute work sessions, 5-minute breaks
- 🎵 **Spotify Integration**: Auto-pause music during breaks, auto-resume during work
- 🎚️ **Smooth Fades**: Configurable fade in/out transitions (instant to 5 seconds)
- 🔔 **Browser Notifications**: Get notified when sessions complete
- ⚙️ **Customizable**: Adjust work/break durations and music behavior
- 💾 **Persistent Settings**: Your preferences are saved in localStorage
- 🔐 **Secure OAuth**: PKCE authentication (no backend required!)

## Quick Start

### 1. Set Up Spotify Developer App

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account (free)
3. Click **"Create an App"**
4. Fill in:
   - **App Name**: Pomodo (or your choice)
   - **App Description**: Pomodoro timer with Spotify integration
   - **Redirect URI**: `http://localhost:8000/callback.html`
5. Click **"Save"**
6. Copy your **Client ID**

### 2. Configure the App

Open `js/spotify-auth.js` and update line 8:

```javascript
CLIENT_ID: 'YOUR_CLIENT_ID', // Replace with your Spotify Client ID
```

### 3. Run a Local Server

You need to serve the files over HTTP (PKCE requires it). Choose one:

**Option A: Python (if installed)**
```bash
# Python 3
cd prototype
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

**Option B: Node.js (if installed)**
```bash
npm install -g http-server
cd prototype
http-server -p 8000
```

**Option C: VS Code**
- Install "Live Server" extension
- Right-click `index.html` → "Open with Live Server"
- Change port to 8000 in settings if needed

### 4. Open the App

Navigate to: `http://localhost:8000/index.html`

### 5. Connect Spotify

1. Click **"Connect Spotify"** button
2. Log in to Spotify (if not already)
3. Click **"Agree"** to authorize the app
4. You'll be redirected back to Pomodo

**Note**: Spotify Premium is required for playback control.

## How to Use

### Basic Timer

1. Click **"Start"** to begin a 25-minute work session
2. Work until the timer completes
3. Take a 5-minute break
4. Repeat!

### With Spotify

1. Start playing music on Spotify (desktop app, web player, mobile, etc.)
2. Connect Spotify in Pomodo
3. Start the timer
4. Music will automatically:
   - Fade out and pause when work session ends (break time!)
   - Fade in and resume when break ends (back to work!)

### Settings

- **Auto-pause during breaks**: Toggle music pause behavior
- **Auto-resume during work**: Toggle music resume behavior
- **Fade duration**: Choose transition smoothness (instant to 5 seconds)
- **Work duration**: Customize work session length (1-60 minutes)
- **Break duration**: Customize break length (1-30 minutes)

## Project Structure

```
prototype/
├── index.html              Main app page
├── callback.html           OAuth callback page
├── js/
│   ├── spotify-auth.js     PKCE authentication
│   ├── spotify-api.js      Playback control + fade logic
│   ├── timer.js            Pomodoro timer logic
│   └── app.js              Main application wiring
├── css/
│   └── styles.css          Styling
└── README.md               This file
```

## How It Works

### PKCE Authentication Flow

1. Generate random `code_verifier` and `code_challenge` (SHA-256 hash)
2. Redirect user to Spotify with the challenge
3. User authorizes the app
4. Spotify redirects back with an authorization `code`
5. Exchange code + verifier for access token (all in browser!)
6. Store tokens in localStorage
7. Use tokens to make API calls

**No backend needed!** PKCE is designed for this.

### Fade Transitions

When the timer triggers a session change:

1. Get current playback state and volume
2. Gradually adjust volume in 20 steps over configured duration
3. Pause/resume playback
4. Restore original volume (for next play)

Example: 3-second fade = 20 steps × 150ms each

### Token Management

- Access tokens expire after 1 hour
- Automatically refreshed using refresh token
- 5-minute buffer before expiry to avoid interruptions
- All handled transparently in the background

## Requirements

- **Browser**: Modern browser with JavaScript enabled
- **Spotify**: Premium account (free tier cannot control playback)
- **Active Session**: Music must be playing on a Spotify device

## Limitations

- **Spotify Premium Only**: Free tier users cannot control playback via API
- **Active Device Required**: User must have Spotify open somewhere
- **Same Browser**: Tokens stored in localStorage (device-specific)
- **HTTPS in Production**: Spotify requires HTTPS for production redirect URIs
  - For local development, `http://localhost` is allowed

## Deployment

### GitHub Pages (Free)

1. Create a new repository on GitHub
2. Push this code
3. Enable GitHub Pages in repo settings
4. Update redirect URI in Spotify Dashboard to: `https://username.github.io/repo-name/callback.html`
5. Update `REDIRECT_URI` in `js/spotify-auth.js`

### Netlify/Vercel (Free)

1. Push code to GitHub
2. Connect repo to Netlify or Vercel
3. Deploy (automatic)
4. Update redirect URIs (both Spotify Dashboard and code)

## Troubleshooting

### "No active device found"

**Solution**: Start playing music on Spotify (any device) before using the timer.

### "Spotify Premium required"

**Solution**: Playback control requires a Premium subscription. Upgrade at spotify.com/premium

### "Authorization failed"

**Solution**:
- Check your Client ID is correct
- Check redirect URI matches exactly (including port)
- Make sure redirect URI is added in Spotify Dashboard

### Tokens not refreshing

**Solution**:
- Check browser console for errors
- Try logging out and back in
- Clear localStorage and reconnect

### CORS errors

**Solution**:
- Must run via HTTP server (not `file://`)
- Use one of the local server options above

## Browser Support

Requires modern browser with:
- ES6+ JavaScript support
- Web Crypto API (for PKCE)
- localStorage
- Fetch API
- Notification API (optional, for alerts)

Tested on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Future Enhancements

Potential features to add:
- Long break after 4 work sessions
- Custom notification sounds
- Statistics tracking (sessions completed, focus time)
- Dark mode
- Keyboard shortcuts
- Multiple timer presets
- Desktop app (Electron) with system tray
- Volume control slider
- Play/pause button for manual control

## Contributing

This is a proof-of-concept! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Use as a starting point for your own project

## License

MIT License - use however you like!

## Resources

- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api)
- [PKCE Flow Guide](https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow)
- [Pomodoro Technique](https://francescocirillo.com/pages/pomodoro-technique)

## Support

Found a bug? Have a question?
- Open an issue on GitHub
- Check the console for error messages
- Make sure Spotify Premium is active
- Verify redirect URIs match exactly

---

Built with ❤️ and JavaScript
