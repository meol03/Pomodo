//
//  AppTheme.swift
//  Pomodo (macOS)
//
//  Theme definitions with colors for work and break modes
//

import SwiftUI

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

    // Ambient animation type
    let ambientType: AmbientType

    enum AmbientType {
        case rain
        case snow
        case cherryBlossoms
        case sunRays
        case fallingLeaves
        case cityLights
    }

    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Predefined Themes
extension AppTheme {
    static let cozy = AppTheme(
        id: "cozy",
        name: "Cozy Study",
        icon: "cloud.rain.fill",
        workBackgroundPrimary: Color(hex: "#2C1810"),
        workBackgroundSecondary: Color(hex: "#1A0F0A"),
        workAccent: Color(hex: "#D4956A"),
        workText: Color(hex: "#F5E6D3"),
        breakBackgroundPrimary: Color(hex: "#1A2F1A"),
        breakBackgroundSecondary: Color(hex: "#0F1F0F"),
        breakAccent: Color(hex: "#7CB87C"),
        breakText: Color(hex: "#E8F5E8"),
        ambientType: .rain
    )

    static let night = AppTheme(
        id: "night",
        name: "Night City",
        icon: "moon.stars.fill",
        workBackgroundPrimary: Color(hex: "#0D0D1A"),
        workBackgroundSecondary: Color(hex: "#1A1A2E"),
        workAccent: Color(hex: "#FF6B9D"),
        workText: Color(hex: "#E8E8FF"),
        breakBackgroundPrimary: Color(hex: "#0A1A2A"),
        breakBackgroundSecondary: Color(hex: "#152238"),
        breakAccent: Color(hex: "#00D4FF"),
        breakText: Color(hex: "#E8F8FF"),
        ambientType: .cityLights
    )

    static let winter = AppTheme(
        id: "winter",
        name: "Winter",
        icon: "snowflake",
        workBackgroundPrimary: Color(hex: "#1A2A3A"),
        workBackgroundSecondary: Color(hex: "#0F1A25"),
        workAccent: Color(hex: "#87CEEB"),
        workText: Color(hex: "#F0F8FF"),
        breakBackgroundPrimary: Color(hex: "#2A3A4A"),
        breakBackgroundSecondary: Color(hex: "#1A2A3A"),
        breakAccent: Color(hex: "#B0E0E6"),
        breakText: Color(hex: "#F5FFFA"),
        ambientType: .snow
    )

    static let spring = AppTheme(
        id: "spring",
        name: "Spring",
        icon: "leaf.fill",
        workBackgroundPrimary: Color(hex: "#2D1F2D"),
        workBackgroundSecondary: Color(hex: "#1A121A"),
        workAccent: Color(hex: "#FFB7C5"),
        workText: Color(hex: "#FFF0F5"),
        breakBackgroundPrimary: Color(hex: "#1F2D1F"),
        breakBackgroundSecondary: Color(hex: "#121A12"),
        breakAccent: Color(hex: "#98D998"),
        breakText: Color(hex: "#F0FFF0"),
        ambientType: .cherryBlossoms
    )

    static let summer = AppTheme(
        id: "summer",
        name: "Summer",
        icon: "sun.max.fill",
        workBackgroundPrimary: Color(hex: "#1A2A3A"),
        workBackgroundSecondary: Color(hex: "#2A3A4A"),
        workAccent: Color(hex: "#FFD700"),
        workText: Color(hex: "#FFFACD"),
        breakBackgroundPrimary: Color(hex: "#2A3A2A"),
        breakBackgroundSecondary: Color(hex: "#1A2A1A"),
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
        workText: Color(hex: "#FFF8DC"),
        breakBackgroundPrimary: Color(hex: "#1A2A1A"),
        breakBackgroundSecondary: Color(hex: "#0F1A0F"),
        breakAccent: Color(hex: "#8FBC8F"),
        breakText: Color(hex: "#F5FFFA"),
        ambientType: .fallingLeaves
    )

    static let allThemes: [AppTheme] = [
        .cozy, .night, .winter, .spring, .summer, .fall
    ]

    static func theme(for id: String) -> AppTheme {
        allThemes.first { $0.id == id } ?? .cozy
    }
}
