//
//  ControlsView.swift
//  Pomodo (macOS)
//
//  Timer control buttons
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var viewModel: PomodoroViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 24) {
            // Reset Button
            ControlButton(
                icon: "arrow.counterclockwise",
                size: .small,
                action: { viewModel.reset() }
            )
            .help("Reset Timer (⌘R)")

            // Play/Pause Button
            ControlButton(
                icon: viewModel.timerState.status == .running ? "pause.fill" : "play.fill",
                size: .large,
                isPrimary: true,
                accentColor: themeManager.accentColor,
                action: { viewModel.toggleTimer() }
            )
            .help(viewModel.timerState.status == .running ? "Pause (Space)" : "Start (Space)")

            // Skip Button
            ControlButton(
                icon: "forward.fill",
                size: .small,
                action: { viewModel.skipToNextSession() }
            )
            .help("Skip to Next Session (⌘N)")
        }
    }
}

// MARK: - Control Button
struct ControlButton: View {
    enum Size {
        case small, large

        var dimension: CGFloat {
            switch self {
            case .small: return 48
            case .large: return 64
            }
        }

        var iconSize: Font {
            switch self {
            case .small: return .title2
            case .large: return .title
            }
        }
    }

    let icon: String
    let size: Size
    var isPrimary: Bool = false
    var accentColor: Color = .white
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.iconSize)
                .frame(width: size.dimension, height: size.dimension)
                .background(
                    isPrimary
                        ? accentColor
                        : (isHovered ? Color.white.opacity(0.15) : Color.white.opacity(0.1))
                )
                .foregroundColor(isPrimary ? .white : .white.opacity(0.8))
                .clipShape(Circle())
                .scaleEffect(isHovered ? 1.05 : 1.0)
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
    ControlsView()
        .environmentObject(PomodoroViewModel())
        .environmentObject(ThemeManager())
        .padding()
        .background(Color.black)
}
