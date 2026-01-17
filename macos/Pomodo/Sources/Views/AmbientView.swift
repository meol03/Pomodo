//
//  AmbientView.swift
//  Pomodo (macOS)
//
//  Background ambient animations for different themes
//

import SwiftUI

struct AmbientView: View {
    let type: AppTheme.AmbientType

    var body: some View {
        switch type {
        case .rain:
            RainView()
        case .snow:
            SnowView()
        case .cherryBlossoms:
            CherryBlossomView()
        case .sunRays:
            SunRaysView()
        case .fallingLeaves:
            FallingLeavesView()
        case .cityLights:
            CityLightsView()
        }
    }
}

// MARK: - Rain
struct RainView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<25, id: \.self) { i in
                RainDrop(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    height: geometry.size.height,
                    delay: Double.random(in: 0...2)
                )
            }
        }
    }
}

struct RainDrop: View {
    let startX: CGFloat
    let height: CGFloat
    let delay: Double

    @State private var offset: CGFloat = -50

    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 1.5, height: 15)
            .offset(x: startX, y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: 0.8)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 50
                }
            }
    }
}

// MARK: - Snow
struct SnowView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<30, id: \.self) { i in
                Snowflake(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 3...8),
                    height: geometry.size.height,
                    delay: Double.random(in: 0...3)
                )
            }
        }
    }
}

struct Snowflake: View {
    let startX: CGFloat
    let size: CGFloat
    let height: CGFloat
    let delay: Double

    @State private var offset: CGFloat = -20
    @State private var horizontalOffset: CGFloat = 0

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.7))
            .frame(width: size, height: size)
            .offset(x: startX + horizontalOffset, y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 4...7))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 20
                    horizontalOffset = CGFloat.random(in: -20...20)
                }
            }
    }
}

// MARK: - Cherry Blossoms
struct CherryBlossomView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<15, id: \.self) { i in
                Petal(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 6...12),
                    height: geometry.size.height,
                    delay: Double.random(in: 0...4)
                )
            }
        }
    }
}

struct Petal: View {
    let startX: CGFloat
    let size: CGFloat
    let height: CGFloat
    let delay: Double

    @State private var offset: CGFloat = -30
    @State private var rotation: Double = 0

    var body: some View {
        Ellipse()
            .fill(Color.pink.opacity(0.5))
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .offset(x: startX, y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 5...9))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 30
                    rotation = 360
                }
            }
    }
}

// MARK: - Sun Rays
struct SunRaysView: View {
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sun glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.25),
                                Color.yellow.opacity(0)
                            ],
                            center: .center,
                            startRadius: 15,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .position(x: geometry.size.width * 0.85, y: 40)

                // Rotating rays
                ForEach(0..<8, id: \.self) { i in
                    Rectangle()
                        .fill(Color.yellow.opacity(0.12))
                        .frame(width: 3, height: 80)
                        .offset(y: -60)
                        .rotationEffect(.degrees(Double(i) * 45 + rotation))
                }
                .position(x: geometry.size.width * 0.85, y: 40)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Falling Leaves
struct FallingLeavesView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<12, id: \.self) { i in
                FallingLeaf(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 10...16),
                    height: geometry.size.height,
                    color: [Color.orange, Color.red, Color(hex: "#D2691E")].randomElement()!,
                    delay: Double.random(in: 0...5)
                )
            }
        }
    }
}

struct FallingLeaf: View {
    let startX: CGFloat
    let size: CGFloat
    let height: CGFloat
    let color: Color
    let delay: Double

    @State private var offset: CGFloat = -30
    @State private var rotation: Double = 0
    @State private var horizontalOffset: CGFloat = 0

    var body: some View {
        Image(systemName: "leaf.fill")
            .font(.system(size: size))
            .foregroundColor(color.opacity(0.6))
            .rotationEffect(.degrees(rotation))
            .offset(x: startX + horizontalOffset, y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 6...10))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 30
                    rotation = Double.random(in: 180...540)
                    horizontalOffset = CGFloat.random(in: -40...40)
                }
            }
    }
}

// MARK: - City Lights
struct CityLightsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<15, id: \.self) { i in
                    CityLight(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: geometry.size.height * 0.3...geometry.size.height * 0.6)
                    )
                }
            }
        }
    }
}

struct CityLight: View {
    let x: CGFloat
    let y: CGFloat

    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(
                [Color.yellow, Color.orange, Color.cyan, Color.pink].randomElement()!
            )
            .opacity(opacity)
            .frame(width: CGFloat.random(in: 2...6))
            .position(x: x, y: y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1...3))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.5...0.8)
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black
        AmbientView(type: .snow)
    }
    .frame(width: 400, height: 300)
}
