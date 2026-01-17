//
//  AmbientView.swift
//  Pomodo
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
            ForEach(0..<30, id: \.self) { i in
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
            .frame(width: 2, height: 20)
            .offset(x: startX, y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: 1)
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
            ForEach(0..<40, id: \.self) { i in
                Snowflake(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 4...10),
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
                    .linear(duration: Double.random(in: 4...8))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 20
                    horizontalOffset = CGFloat.random(in: -30...30)
                }
            }
    }
}

// MARK: - Cherry Blossoms
struct CherryBlossomView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20, id: \.self) { i in
                Petal(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 8...15),
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
            .fill(Color.pink.opacity(0.6))
            .frame(width: size, height: size * 0.6)
            .rotationEffect(.degrees(rotation))
            .offset(x: startX, y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 5...10))
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
                                Color.yellow.opacity(0.3),
                                Color.yellow.opacity(0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(x: geometry.size.width * 0.85, y: 50)

                // Rotating rays
                ForEach(0..<8, id: \.self) { i in
                    Rectangle()
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 4, height: 100)
                        .offset(y: -80)
                        .rotationEffect(.degrees(Double(i) * 45 + rotation))
                }
                .position(x: geometry.size.width * 0.85, y: 50)
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
            ForEach(0..<15, id: \.self) { i in
                FallingLeaf(
                    startX: CGFloat.random(in: 0...geometry.size.width),
                    size: CGFloat.random(in: 12...20),
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
            .foregroundColor(color.opacity(0.7))
            .rotationEffect(.degrees(rotation))
            .offset(x: startX + horizontalOffset, y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 6...12))
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = height + 30
                    rotation = Double.random(in: 180...720)
                    horizontalOffset = CGFloat.random(in: -50...50)
                }
            }
    }
}

// MARK: - City Lights
struct CityLightsView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Distant building lights
                ForEach(0..<20, id: \.self) { i in
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
            .frame(width: CGFloat.random(in: 3...8))
            .position(x: x, y: y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1...3))
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = Double.random(in: 0.5...0.9)
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black
        AmbientView(type: .rain)
    }
    .ignoresSafeArea()
}
