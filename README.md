# Pomodo - Lo-Fi Study Timer

A beautiful, distraction-free Pomodoro timer that combines proven productivity techniques with a cozy, lo-fi aesthetic to create the perfect focus environment.

## The Problem

Students and remote workers struggle with focus and time management. Existing productivity tools are either too complex, visually overwhelming, or lack the calming aesthetic that promotes sustained concentration.

## The Solution

Pomodo is a single-page web application that helps you stay focused using the Pomodoro Technique while creating a calming, immersive work environment through beautiful lo-fi visuals and animations.

## Key Features

### Pomodoro Timer System
- 25-minute work sessions followed by 5-minute breaks
- Longer 15-minute break after every 4 sessions
- Fully customizable intervals to suit different work styles
- Visual and audio notifications when timers complete

### Immersive Visual Experience
- Cozy illustrated study room with animated elements
- Steaming coffee cup animation
- Moving wall clock
- Rain animation during work sessions
- Color palette shifts to signal breaks vs. work time
- Smooth transitions between work and break modes

### Progress Tracking
- Session counter shows where you are in the 4-session cycle
- Daily Pomodoro completion statistics
- Data persists in browser localStorage
- No account required - works offline

### Customizable Settings
- Adjust work session duration
- Customize short break length
- Set long break duration
- Toggle notifications on/off
- Settings saved locally

## How to Use

1. Open `index.html` in your web browser
2. Click "Start" to begin your first 25-minute focus session
3. Work until the timer completes and you're notified
4. Take a 5-minute break when prompted
5. After 4 work sessions, enjoy a 15-minute long break
6. Click the settings gear icon to customize timer durations

## Technologies Used

- Pure HTML5, CSS3, and JavaScript (no frameworks required)
- CSS Grid and Flexbox for responsive layout
- CSS animations for visual effects
- LocalStorage API for data persistence
- Notifications API for desktop notifications
- Responsive design for mobile and desktop

## Browser Compatibility

Works on all modern browsers that support:
- ES6 JavaScript
- CSS Custom Properties (variables)
- LocalStorage API
- Notifications API (optional, for alerts)

Tested on Chrome, Firefox, Safari, and Edge.

## Installation

### Option 1: Download and Run Locally
1. Download all files (index.html, styles.css, app.js)
2. Open `index.html` in your web browser
3. Start focusing!

### Option 2: Host on GitHub Pages
1. Fork this repository
2. Go to Settings > Pages
3. Select your branch and save
4. Your timer will be live at `https://yourusername.github.io/Pomodo`

### Option 3: Deploy to Netlify/Vercel
Simply drag and drop the project folder into Netlify or Vercel for instant deployment.

## Features in Detail

### Session Tracking
- Visual dots show your progress through the 4-session cycle
- Active session is highlighted with a glowing effect
- Completed sessions are marked with a different color
- Cycle resets after the long break

### Visual Modes
- **Work Mode**: Dark, focused color scheme with subtle rain animation
- **Break Mode**: Lighter, calming colors to encourage relaxation
- Smooth color transitions create a pleasant visual experience

### Notifications
- Desktop notifications when timers complete
- Encouragement messages for different timer events
- Audio chime (can be disabled in settings)
- Permission requested on first load

### Statistics
- Track daily Pomodoro completions
- Counter displays total sessions completed today
- Stats reset automatically at midnight
- Persistent across browser sessions

## Keyboard Shortcuts

- `Space`: Start/Pause timer
- `R`: Reset current timer
- `S`: Open settings

## Why Pomodo?

- **Research-backed**: The Pomodoro Technique is proven to improve focus and prevent burnout
- **Beautiful**: Lo-fi aesthetic has millions of followers - people love this visual style
- **Simple**: No account, no complexity - just open and start
- **Free**: Open source and free forever
- **Private**: All data stays in your browser
- **Offline**: Works without internet connection

## The Pomodoro Technique

The Pomodoro Technique was developed by Francesco Cirillo in the late 1980s. It breaks work into intervals (traditionally 25 minutes) separated by short breaks. This helps maintain focus and prevents mental fatigue.

**The cycle:**
1. Choose a task
2. Work for 25 minutes (1 Pomodoro)
3. Take a 5-minute break
4. After 4 Pomodoros, take a longer 15-minute break
5. Repeat

## Customization

Want to modify the app? Here's what you can easily change:

- **Colors**: Edit CSS custom properties in `styles.css` (lines 3-24)
- **Default durations**: Modify the `settings` object in `app.js` (lines 6-10)
- **Animations**: Adjust keyframe animations in `styles.css`
- **Study room design**: Modify the `.study-room` section in `index.html` and corresponding CSS

## Future Enhancement Ideas

- Sound effects and lo-fi music integration
- More visual themes (night mode, seasons, etc.)
- Weekly/monthly statistics dashboard
- Task list integration
- Multiple preset timer configurations
- Export statistics as CSV
- Background sound options (rain, cafe, etc.)

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## License

MIT License - feel free to use this project for personal or commercial purposes.

## Credits

Built with focus and calm. Inspired by the lo-fi study community and productivity enthusiasts worldwide.

## Support

If you find this helpful, please star the repository and share it with others who might benefit from better focus tools!