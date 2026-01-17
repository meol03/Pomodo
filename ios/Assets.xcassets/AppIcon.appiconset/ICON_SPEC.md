# Pomodo App Icon Specification

## Design Concept
A cute, friendly tomato (pomodoro) with a minimalist design that works well at all sizes.

## Icon Design

### Primary Elements
- **Background**: Warm gradient from `#FF6B6B` to `#EE5A5A` (tomato red)
- **Tomato Body**: Rounded square shape filling 80% of the icon
- **Leaf/Stem**: Small green accent `#4CAF50` at the top
- **Optional**: Subtle face or timer indicator

### Color Palette
| Element | Light Mode | Hex |
|---------|-----------|-----|
| Background | Tomato Red | #FF6B6B |
| Background Gradient | Darker Red | #EE5A5A |
| Leaf | Green | #4CAF50 |
| Highlight | Light Red | #FF8A8A |
| Shadow | Dark Red | #CC4444 |

### Size Requirements

| Size | Scale | Pixels | Usage |
|------|-------|--------|-------|
| 20pt | @2x | 40x40 | Notification |
| 20pt | @3x | 60x60 | Notification |
| 29pt | @2x | 58x58 | Settings |
| 29pt | @3x | 87x87 | Settings |
| 40pt | @2x | 80x80 | Spotlight |
| 40pt | @3x | 120x120 | Spotlight |
| 60pt | @2x | 120x120 | Home Screen |
| 60pt | @3x | 180x180 | Home Screen |
| 1024pt | @1x | 1024x1024 | App Store |

## Generation Instructions

### Option 1: Using Figma/Sketch
1. Create a 1024x1024 artboard
2. Design the icon following the spec above
3. Export at all required sizes

### Option 2: Using SF Symbols + SwiftUI
The app can use a system symbol as a placeholder:
```swift
Image(systemName: "leaf.circle.fill")
    .foregroundStyle(.red)
```

### Option 3: Online Generator
1. Create a 1024x1024 PNG
2. Use https://appicon.co to generate all sizes
3. Download and replace files in this folder

## File Naming Convention
- `icon-{size}@{scale}x.png`
- Example: `icon-60@3x.png` for 180x180 pixels

## Quick Start SVG
See `icon-source.svg` in this folder for a starting point.
