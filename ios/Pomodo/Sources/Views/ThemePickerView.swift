//
//  ThemePickerView.swift
//  Pomodo
//
//  Theme selection sheet
//

import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(AppTheme.allThemes) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: theme.id == themeManager.currentTheme.id
                        ) {
                            themeManager.setTheme(theme)
                            HapticManager.shared.selection()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Theme Card
struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

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
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? theme.workAccent : Color.clear,
                            lineWidth: 3
                        )
                )

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
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ThemePickerView()
        .environmentObject(ThemeManager())
}
