//
//  StudyRoomView.swift
//  Pomodo
//
//  Illustrated study room with desk, coffee, cactus, and clock
//

import SwiftUI

struct StudyRoomView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var steamOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                // Desk surface
                DeskView(width: width, height: height)
                    .position(x: width / 2, y: height * 0.75)

                // Coffee cup
                CoffeeView()
                    .frame(width: 50, height: 60)
                    .position(x: width * 0.25, y: height * 0.55)

                // Cactus
                CactusView()
                    .frame(width: 40, height: 70)
                    .position(x: width * 0.75, y: height * 0.5)

                // Books stack
                BooksView()
                    .frame(width: 60, height: 50)
                    .position(x: width * 0.5, y: height * 0.55)

                // Wall clock
                WallClockView()
                    .frame(width: 60, height: 60)
                    .position(x: width * 0.85, y: height * 0.15)
            }
        }
    }
}

// MARK: - Desk
struct DeskView: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "#8B4513"), Color(hex: "#654321")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width * 0.9, height: height * 0.15)
            .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
    }
}

// MARK: - Coffee Cup
struct CoffeeView: View {
    @State private var steamPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Steam animation
            ForEach(0..<3) { i in
                SteamParticle(delay: Double(i) * 0.3)
                    .offset(x: CGFloat(i - 1) * 8, y: -35)
            }

            // Cup body
            ZStack {
                // Cup
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 30, height: 35)

                // Coffee surface
                Ellipse()
                    .fill(Color(hex: "#3E2723"))
                    .frame(width: 26, height: 10)
                    .offset(y: -10)

                // Handle
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 15, height: 15)
                    .offset(x: 20, y: 0)
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
            .frame(width: 8, height: 8)
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

// MARK: - Cactus
struct CactusView: View {
    var body: some View {
        ZStack {
            // Pot
            ZStack {
                // Pot body
                Capsule()
                    .fill(Color(hex: "#D2691E"))
                    .frame(width: 30, height: 25)

                // Pot rim
                Capsule()
                    .fill(Color(hex: "#CD853F"))
                    .frame(width: 34, height: 8)
                    .offset(y: -8)

                // Soil
                Ellipse()
                    .fill(Color(hex: "#3E2723"))
                    .frame(width: 26, height: 8)
                    .offset(y: -5)
            }
            .offset(y: 20)

            // Cactus body
            ZStack {
                // Main body
                Capsule()
                    .fill(Color(hex: "#228B22"))
                    .frame(width: 18, height: 45)

                // Left arm
                Capsule()
                    .fill(Color(hex: "#228B22"))
                    .frame(width: 10, height: 20)
                    .rotationEffect(.degrees(30))
                    .offset(x: -12, y: -5)

                // Right arm
                Capsule()
                    .fill(Color(hex: "#228B22"))
                    .frame(width: 10, height: 15)
                    .rotationEffect(.degrees(-30))
                    .offset(x: 12, y: 5)
            }
            .offset(y: -20)
        }
    }
}

// MARK: - Books
struct BooksView: View {
    var body: some View {
        ZStack {
            // Book 1 (bottom)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#E74C3C"))
                .frame(width: 50, height: 12)
                .offset(y: 12)

            // Book 2 (middle)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#3498DB"))
                .frame(width: 45, height: 10)
                .offset(y: 0)

            // Book 3 (top)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: "#2ECC71"))
                .frame(width: 48, height: 11)
                .offset(y: -12)
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
                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)

            // Clock border
            Circle()
                .stroke(Color(hex: "#8B4513"), lineWidth: 3)

            // Hour marks
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 2, height: 6)
                    .offset(y: -22)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            // Hour hand
            Rectangle()
                .fill(Color.black)
                .frame(width: 3, height: 15)
                .offset(y: -7)
                .rotationEffect(hourAngle)

            // Minute hand
            Rectangle()
                .fill(Color.black)
                .frame(width: 2, height: 20)
                .offset(y: -10)
                .rotationEffect(minuteAngle)

            // Center dot
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }

    var hourAngle: Angle {
        let hour = Calendar.current.component(.hour, from: currentTime) % 12
        let minute = Calendar.current.component(.minute, from: currentTime)
        return .degrees(Double(hour) * 30 + Double(minute) * 0.5)
    }

    var minuteAngle: Angle {
        let minute = Calendar.current.component(.minute, from: currentTime)
        return .degrees(Double(minute) * 6)
    }
}

#Preview {
    StudyRoomView()
        .environmentObject(ThemeManager())
        .frame(height: 200)
        .background(Color.black)
}
