# 🍅 Pomodo

A Pomodoro timer with Spotify integration featuring automatic music control and smooth fade transitions.

## Project Status

This repository contains research and a working proof-of-concept for integrating Spotify with a Pomodoro timer application.

## What's Inside

### 📚 Documentation

**[SPOTIFY_INTEGRATION.md](SPOTIFY_INTEGRATION.md)** - Comprehensive integration guide covering:
- Spotify vs Apple Music API comparison
- PKCE authentication flow (no backend required!)
- Standard OAuth flow (with backend)
- Playback control implementation
- Fade in/out feature specification
- Tech stack recommendations
- Security best practices
- Deployment guide

### 🚀 Working Proof-of-Concept

**[prototype/](prototype/)** - Fully functional Pomodo timer with:
- ⏱️ Customizable Pomodoro timer (default: 25 min work, 5 min break)
- 🎵 Spotify integration with PKCE authentication
- 🎚️ Auto-pause/resume music with smooth fades (0-5 seconds)
- ⚙️ Persistent user settings
- 🔔 Browser notifications
- 📱 Responsive design
- 💯 **Zero dependencies** - pure vanilla JavaScript!

**Tech Stack**: HTML, CSS, JavaScript (ES6+)
**Backend**: None! Uses PKCE for client-side OAuth

## Quick Start

### Try the Prototype

1. **Get Spotify credentials**:
   - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Create an app
   - Copy your Client ID
   - Add redirect URI: `http://localhost:8000/callback.html`

2. **Configure**:
   ```bash
   cd prototype
   # Edit js/spotify-auth.js line 8:
   # CLIENT_ID: 'YOUR_CLIENT_ID'
   ```

3. **Run**:
   ```bash
   python -m http.server 8000
   # Or: npx http-server -p 8000
   ```

4. **Open**: http://localhost:8000/index.html

5. **Connect Spotify** and start focusing!

**Note**: Requires Spotify Premium for playback control.

## Key Features

### What Makes This Special

✅ **No Backend Required**
- Uses PKCE OAuth flow (designed for SPAs)
- All authentication happens in the browser
- Deploy as static files anywhere

✅ **Simple Integration**
- Controls existing Spotify playback
- Doesn't replace your music player
- Works with any Spotify device

✅ **Smart Fade Transitions**
- Smooth volume adjustments (20-step algorithm)
- Configurable duration (instant to 5 seconds)
- Restores original volume after fade

✅ **User-Friendly**
- Clean, focused UI
- Customizable durations
- Persistent settings
- Browser notifications

## How It Works

### The Music Integration Flow

```
Timer reaches end of work session
  ↓
Trigger fade out (if enabled)
  ↓
Gradually decrease volume: 100% → 75% → 50% → 25% → 0%
  ↓
Pause Spotify playback
  ↓
Restore volume to original level
  ↓
Break session begins (music paused)

---

Break ends
  ↓
Trigger fade in (if enabled)
  ↓
Set volume to 0%, resume playback
  ↓
Gradually increase volume: 0% → 25% → 50% → 75% → 100%
  ↓
Work session begins (music playing)
```

### PKCE Authentication (No Backend!)

```
1. Generate random code_verifier (64 bytes)
2. Hash it to create code_challenge (SHA-256)
3. Send challenge to Spotify (no secret needed!)
4. User authorizes
5. Spotify redirects with authorization code
6. Exchange code + verifier for tokens (in browser!)
7. Store tokens in localStorage
8. Auto-refresh when expired
```

**Security**: PKCE is specifically designed for public clients and is the recommended OAuth flow for SPAs.

## Research Summary

### Spotify vs Apple Music

| Feature | Spotify | Apple Music |
|---------|---------|-------------|
| **Developer Cost** | Free | $99/year |
| **User Requirement** | Premium subscription | Apple Music subscription |
| **Web Integration** | Excellent (PKCE support) | Good (MusicKit JS) |
| **Auth Complexity** | Simple (PKCE) | Complex (JWT tokens) |
| **Recommendation** | ✅ Best for MVP | Consider if building iOS app |

### Can You Do It Without a Backend?

**YES!** Using PKCE (Proof Key for Code Exchange):
- No server needed
- No client secret required
- Perfect for static hosting
- Free deployment (GitHub Pages, Netlify, Vercel)

## Deployment Options

### Free Static Hosting

All of these work with the PKCE approach:

1. **GitHub Pages**
   - Push code, enable in settings
   - URL: `username.github.io/pomodo`
   - Cost: $0

2. **Vercel**
   - Connect repo, auto-deploy
   - Custom domain support
   - Cost: $0

3. **Netlify**
   - Drag & drop or Git integration
   - Instant cache invalidation
   - Cost: $0

**Important**: Update redirect URIs to your production URL in both:
- Spotify Developer Dashboard
- `js/spotify-auth.js` (REDIRECT_URI)

## Project Structure

```
Pomodo/
├── README.md                    # This file
├── SPOTIFY_INTEGRATION.md       # Detailed integration guide
└── prototype/                   # Working proof-of-concept
    ├── README.md                # Setup instructions
    ├── index.html               # Main app
    ├── callback.html            # OAuth callback
    ├── js/
    │   ├── spotify-auth.js      # PKCE authentication
    │   ├── spotify-api.js       # Playback + fade logic
    │   ├── timer.js             # Pomodoro timer
    │   └── app.js               # Main application
    └── css/
        └── styles.css           # Styling
```

## Requirements

### For Development
- Modern web browser
- HTTP server (Python, Node, or any)
- Spotify Developer account (free)

### For Users
- Modern web browser
- Spotify Premium account
- Active Spotify session (desktop, web, or mobile)

## Browser Support

Tested and working on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

Requires:
- ES6+ JavaScript
- Web Crypto API (for PKCE)
- localStorage
- Fetch API
- Notification API (optional)

## Future Enhancements

Potential features to explore:
- [ ] Long break after 4 pomodoros
- [ ] Statistics tracking
- [ ] Dark mode
- [ ] Keyboard shortcuts
- [ ] Desktop app (Electron)
- [ ] Apple Music support
- [ ] Playlist recommendations
- [ ] Focus music suggestions
- [ ] Task integration (Todoist, Notion)
- [ ] Team/group sessions

## Contributing

This is an open research project! Contributions welcome:
- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit PRs
- 📖 Improve documentation
- ⭐ Star if you find it useful!

## Resources

### Documentation
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [PKCE Flow Guide](https://developer.spotify.com/documentation/web-api/tutorials/code-pkce-flow)
- [Apple Music API](https://developer.apple.com/documentation/applemusicapi/)
- [Pomodoro Technique](https://francescocirillo.com/pages/pomodoro-technique)

### Community
- [Spotify Developer Forum](https://community.spotify.com/t5/Spotify-for-Developers/bd-p/Spotify_Developer)
- Stack Overflow: `spotify-web-api`

## License

MIT License - feel free to use however you like!

## Acknowledgments

- Spotify for providing an excellent Web API
- The Pomodoro Technique by Francesco Cirillo
- All the developers who asked "can I do this without a backend?"

---

**Built with ❤️ and JavaScript**

*Focus better. Work smarter. Rock on.* 🎸
