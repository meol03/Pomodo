//
//  StudyRoomView.swift
//  Pomodo (macOS)
//
//  Illustrated study room with animated elements
//

import SwiftUI

struct StudyRoomView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Desk
                DeskView()
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.7)

                // Coffee cup
                CoffeeView()
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)

                // Plant
                PlantView()
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.5)

                // Books
                BooksView()
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.55)

                // Wall Clock
                WallClockView()
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
            }
        }
    }
}

// MARK: - Desk
struct DeskView: View {
    var body: some View {
        ZStack {
            // Desk top
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#8B4513"), Color(hex: "#654321")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 300, height: 20)

            // Desk front
            Rectangle()
                .fill(Color(hex: "#654321"))
                .frame(width: 300, height: 60)
                .offset(y: 40)
        }
    }
}

// MARK: - Coffee Cup
struct CoffeeView: View {
    @State private var steamOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Steam
            ForEach(0..<3, id: \.self) { i in
                SteamParticle(delay: Double(i) * 0.3)
                    .offset(x: CGFloat(i - 1) * 8, y: -40)
            }

            // Cup
            ZStack {
                // Cup body
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 30, height: 35)

                // Coffee
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#4A2C2A"))
                    .frame(width: 24, height: 20)
                    .offset(y: -5)

                // Handle
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 15, height: 15)
                    .offset(x: 20)
            }
        }
    }
}

struct SteamParticle: View {
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .fill(Color.white.opacity(opacity))
            .frame(width: 6, height: 6)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offset = -30
                    opacity = 0
                }
            }
    }
}

// MARK: - Plant
struct PlantView: View {
    var body: some View {
        ZStack {
            // Pot
            ZStack {
                // Pot body
                Trapezoid()
                    .fill(Color(hex: "#CD5C5C"))
                    .frame(width: 35, height: 30)

                // Pot rim
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#B84C4C"))
                    .frame(width: 40, height: 6)
                    .offset(y: -15)
            }

            // Cactus body
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#228B22"))
                .frame(width: 20, height: 40)
                .offset(y: -40)

            // Cactus arms
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "#228B22"))
                .frame(width: 8, height: 20)
                .offset(x: -15, y: -45)

            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "#228B22"))
                .frame(width: 8, height: 15)
                .offset(x: 15, y: -50)
        }
    }
}

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = rect.width * 0.15
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Books
struct BooksView: View {
    var body: some View {
        HStack(spacing: 2) {
            // Book 1
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#E74C3C"))
                .frame(width: 15, height: 45)

            // Book 2
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#3498DB"))
                .frame(width: 12, height: 40)

            // Book 3
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#F1C40F"))
                .frame(width: 18, height: 48)
        }
    }
}

// MARK: - Wall Clock
struct WallClockView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Clock face
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)

            Circle()
                .stroke(Color(hex: "#333333"), lineWidth: 2)
                .frame(width: 40, height: 40)

            // Hour hand
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(width: 2, height: 10)
                .offset(y: -5)
                .rotationEffect(.degrees(hourAngle))

            // Minute hand
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(width: 1.5, height: 14)
                .offset(y: -7)
                .rotationEffect(.degrees(minuteAngle))

            // Center dot
            Circle()
                .fill(Color(hex: "#333333"))
                .frame(width: 4, height: 4)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    private var hourAngle: Double {
        let hour = Calendar.current.component(.hour, from: currentTime)
        let minute = Calendar.current.component(.minute, from: currentTime)
        return Double(hour % 12) * 30 + Double(minute) * 0.5
    }

    private var minuteAngle: Double {
        let minute = Calendar.current.component(.minute, from: currentTime)
        return Double(minute) * 6
    }
}

#Preview {
    StudyRoomView()
        .environmentObject(ThemeManager())
        .frame(width: 400, height: 200)
        .background(Color(hex: "#2C1810"))
}
