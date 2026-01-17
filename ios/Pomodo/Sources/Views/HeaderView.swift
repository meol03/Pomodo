//
//  HeaderView.swift
//  Pomodo
//
//  App header with title, theme picker, and daily stats
//

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack {
            // App title
            Text("Pomodo")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(themeManager.textColor)

            Spacer()

            // Daily stats
            HStack(spacing: 4) {
                Text("🍅")
                Text("\(viewModel.dailyStats.completedPomodoros)")
                    .font(.headline)
                    .foregroundColor(themeManager.textColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(themeManager.accentColor.opacity(0.2))
            )

            // Theme picker button
            Button {
                viewModel.showThemePicker = true
            } label: {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.accentColor)
            }
            .padding(.leading, 8)

            // Settings button
            Button {
                viewModel.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(themeManager.accentColor)
            }
            .padding(.leading, 8)
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
