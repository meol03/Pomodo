//
//  HeaderView.swift
//  Pomodo (macOS)
//
//  Header with title, theme picker, and daily stats
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            // Title
            Text("Pomodo")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.textColor)

            Spacer()

            // Daily Stats
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.red)
                Text("\(viewModel.dailyStats.completedPomodoros)")
                    .foregroundColor(themeManager.textColor)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(themeManager.accentColor.opacity(0.2))
            .clipShape(Capsule())

            // Theme Picker Button
            Button(action: { viewModel.showThemePicker = true }) {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.accentColor)
            }
            .buttonStyle(.plain)
            .help("Change Theme")

            // Settings Button
            Button(action: { viewModel.showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.textColor.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help("Settings")
        }
    }
}

#Preview {
    HeaderView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
}
