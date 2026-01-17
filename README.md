# Pomodo - Lo-Fi Study Timer

**Version 1.1** | A beautiful, distraction-free Pomodoro timer that combines proven productivity techniques with a cozy, lo-fi aesthetic to create the perfect focus environment.

## What's New in V1.1 🎉

- **6 Visual Themes**: Switch between Cozy Study (default), Night City, Winter, Spring, Summer, and Fall themes
- **Keyboard Shortcuts**: Control the timer with Space (start/pause), R (reset), and S (settings)
- **Real-Time Clock**: Wall clock displays actual current time with moving hour and minute hands
- **Theme-Specific Backgrounds**: Each theme features unique atmospheric elements (city skyline, sun rays, snowflakes, cherry blossoms, falling leaves)
- **Enhanced Visuals**: Improved desk items including detailed coffee cup, cute cactus plant, and stacked books
- **Better Legibility**: Fixed theme menu contrast for perfect readability across all themes

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
- **6 Beautiful Themes** with unique color schemes and atmospheres:
  - ☕ **Cozy Study** (Default): Warm tones with gentle rain animation
  - 🌙 **Night City**: Dark blue/purple with animated city skyline and glowing windows
  - ❄️ **Winter**: Cool blues and whites with falling snowflakes
  - 🌸 **Spring**: Soft pinks and purples with floating cherry blossoms
  - ☀️ **Summer**: Bright oranges and yellows with rotating sun rays
  - 🍂 **Fall**: Rich browns and autumn colors with tumbling leaves
- Cozy illustrated study room with detailed desk items
- Steaming coffee cup with realistic coffee liquid
- Cute cactus plant in a terracotta pot
- Stack of three colorful books
- **Real-time wall clock** showing actual current time
- Theme-specific background animations and atmospheric effects
- Color palette shifts to signal breaks vs. work time
- Smooth transitions between themes and modes

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
- **Switch themes** with the palette button (🎨)
- Theme preferences persist across sessions

### Keyboard Shortcuts ⌨️
- **Space**: Start/Pause timer
- **R**: Reset current timer
- **S**: Open settings panel
- Shortcuts work globally except when typing in input fields

## How to Use

1. Open `index.html` in your web browser
2. **Choose your theme** by clicking the 🎨 palette icon (6 themes available!)
3. Click "Start" to begin your first 25-minute focus session (or press **Space**)
4. Work until the timer completes and you're notified
5. Take a 5-minute break when prompted
6. After 4 work sessions, enjoy a 15-minute long break
7. Click the ⚙️ settings icon to customize timer durations
8. Use keyboard shortcuts for quick control: **Space** (start/pause), **R** (reset), **S** (settings)

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

### Visual Themes & Modes
- **6 Unique Themes**: Each with distinct color palettes and atmospheric animations
  - Cozy Study: Classic lo-fi with rain
  - Night City: Urban skyline with glowing windows
  - Winter: Snowy atmosphere with falling snowflakes
  - Spring: Cherry blossom garden vibes
  - Summer: Bright sun with rotating rays
  - Fall: Autumn colors with tumbling leaves
- **Work Mode vs Break Mode**: Each theme has separate color schemes for focus time and breaks
- **Theme Persistence**: Your selected theme is saved and restored on next visit
- **Real-Time Clock**: Shows actual time on the wall clock in each theme
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
- Weekly/monthly statistics dashboard
- Task list integration
- Multiple preset timer configurations
- Export statistics as CSV
- Background sound options (rain, cafe, etc.)
- Mobile app version (iOS/Android)
- Pomodoro analytics and productivity insights

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