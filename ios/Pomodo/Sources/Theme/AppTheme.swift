//
//  AppTheme.swift
//  Pomodo
//
//  Theme system - ported from web CSS themes
//

import SwiftUI

// MARK: - Theme Definition
struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String

    // Work mode colors
    let workBackgroundPrimary: Color
    let workBackgroundSecondary: Color
    let workAccent: Color
    let workText: Color

    // Break mode colors
    let breakBackgroundPrimary: Color
    let breakBackgroundSecondary: Color
    let breakAccent: Color
    let breakText: Color

    // Ambient animation
    let ambientType: AmbientType

    enum AmbientType {
        case rain
        case snow
        case cherryBlossoms
        case sunRays
        case fallingLeaves
        case cityLights
    }
}

// MARK: - All Themes
extension AppTheme {
    static let cozy = AppTheme(
        id: "cozy",
        name: "Cozy Study",
        icon: "cloud.rain.fill",
        workBackgroundPrimary: Color(hex: "#2C1810"),
        workBackgroundSecondary: Color(hex: "#1A0F0A"),
        workAccent: Color(hex: "#D4956A"),
        workText: Color(hex: "#E8D5C4"),
        breakBackgroundPrimary: Color(hex: "#1A2F1A"),
        breakBackgroundSecondary: Color(hex: "#0F1F0F"),
        breakAccent: Color(hex: "#7CB87C"),
        breakText: Color(hex: "#D4E8D4"),
        ambientType: .rain
    )

    static let night = AppTheme(
        id: "night",
        name: "Night City",
        icon: "building.2.fill",
        workBackgroundPrimary: Color(hex: "#0D0D1A"),
        workBackgroundSecondary: Color(hex: "#050510"),
        workAccent: Color(hex: "#FF6B9D"),
        workText: Color(hex: "#E0E0FF"),
        breakBackgroundPrimary: Color(hex: "#0A1A2A"),
        breakBackgroundSecondary: Color(hex: "#051015"),
        breakAccent: Color(hex: "#00D4FF"),
        breakText: Color(hex: "#E0F0FF"),
        ambientType: .cityLights
    )

    static let winter = AppTheme(
        id: "winter",
        name: "Winter",
        icon: "snowflake",
        workBackgroundPrimary: Color(hex: "#1A2A3A"),
        workBackgroundSecondary: Color(hex: "#0F1A25"),
        workAccent: Color(hex: "#87CEEB"),
        workText: Color(hex: "#E8F4F8"),
        breakBackgroundPrimary: Color(hex: "#2A3A4A"),
        breakBackgroundSecondary: Color(hex: "#1A2530"),
        breakAccent: Color(hex: "#B0E0E6"),
        breakText: Color(hex: "#F0F8FF"),
        ambientType: .snow
    )

    static let spring = AppTheme(
        id: "spring",
        name: "Spring",
        icon: "leaf.fill",
        workBackgroundPrimary: Color(hex: "#2D1F2D"),
        workBackgroundSecondary: Color(hex: "#1A121A"),
        workAccent: Color(hex: "#FFB7C5"),
        workText: Color(hex: "#F8E8F0"),
        breakBackgroundPrimary: Color(hex: "#1F2D1F"),
        breakBackgroundSecondary: Color(hex: "#121A12"),
        breakAccent: Color(hex: "#98D998"),
        breakText: Color(hex: "#E8F8E8"),
        ambientType: .cherryBlossoms
    )

    static let summer = AppTheme(
        id: "summer",
        name: "Summer",
        icon: "sun.max.fill",
        workBackgroundPrimary: Color(hex: "#1A2A3A"),
        workBackgroundSecondary: Color(hex: "#0F1A25"),
        workAccent: Color(hex: "#FFD700"),
        workText: Color(hex: "#FFF8E7"),
        breakBackgroundPrimary: Color(hex: "#2A3A2A"),
        breakBackgroundSecondary: Color(hex: "#1A251A"),
        breakAccent: Color(hex: "#90EE90"),
        breakText: Color(hex: "#F0FFF0"),
        ambientType: .sunRays
    )

    static let fall = AppTheme(
        id: "fall",
        name: "Fall",
        icon: "leaf.arrow.triangle.circlepath",
        workBackgroundPrimary: Color(hex: "#2A1A0A"),
        workBackgroundSecondary: Color(hex: "#1A0F05"),
        workAccent: Color(hex: "#D2691E"),
        workText: Color(hex: "#F5DEB3"),
        breakBackgroundPrimary: Color(hex: "#1A2A1A"),
        breakBackgroundSecondary: Color(hex: "#0F1A0F"),
        breakAccent: Color(hex: "#8FBC8F"),
        breakText: Color(hex: "#E8F5E8"),
        ambientType: .fallingLeaves
    )

    static let allThemes: [AppTheme] = [cozy, night, winter, spring, summer, fall]

    static func theme(for id: String) -> AppTheme {
        allThemes.first { $0.id == id } ?? .cozy
    }
}

// MARK: - Theme Environment
struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .cozy
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
