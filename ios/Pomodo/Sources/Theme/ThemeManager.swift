//
//  ThemeManager.swift
//  Pomodo
//
//  Manages theme state and provides colors based on session type
//

import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .cozy
    @Published var isBreakMode: Bool = false

    private let themeKey = "selectedTheme"

    init() {
        loadTheme()
    }

    func loadTheme() {
        let themeId = UserDefaults.standard.string(forKey: themeKey) ?? "cozy"
        currentTheme = AppTheme.theme(for: themeId)
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: themeKey)
    }

    // MARK: - Current Colors
    var backgroundColor: Color {
        isBreakMode ? currentTheme.breakBackgroundPrimary : currentTheme.workBackgroundPrimary
    }

    var backgroundSecondary: Color {
        isBreakMode ? currentTheme.breakBackgroundSecondary : currentTheme.workBackgroundSecondary
    }

    var accentColor: Color {
        isBreakMode ? currentTheme.breakAccent : currentTheme.workAccent
    }

    var textColor: Color {
        isBreakMode ? currentTheme.breakText : currentTheme.workText
    }

    // MARK: - Gradient
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundColor, backgroundSecondary],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
