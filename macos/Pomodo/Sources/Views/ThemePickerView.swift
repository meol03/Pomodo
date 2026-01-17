//
//  ThemePickerView.swift
//  Pomodo (macOS)
//
//  Theme selection sheet
//

import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Choose Theme")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
            .padding()

            Divider()

            // Theme Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppTheme.allThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeManager.currentTheme.id
                        ) {
                            themeManager.setTheme(theme)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 450, height: 350)
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Theme preview
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [theme.workBackgroundPrimary, theme.workBackgroundSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Icon
                    Image(systemName: theme.icon)
                        .font(.largeTitle)
                        .foregroundColor(theme.workAccent)
                }
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? theme.workAccent : Color.clear,
                            lineWidth: 3
                        )
                )
                .shadow(color: isHovered ? theme.workAccent.opacity(0.3) : .clear, radius: 8)

                // Theme name
                HStack {
                    Text(theme.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(theme.workAccent)
                            .font(.caption)
                    }
                }
            }
            .scaleEffect(isHovered ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    ThemePickerView()
        .environmentObject(ThemeManager())
}
