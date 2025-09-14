import SwiftUI

struct WinOverlayView: View {
    @State private var scale: CGFloat = 0
    @State private var opacity: CGFloat = 0
    @State private var star1Scale: CGFloat = 0
    @State private var star2Scale: CGFloat = 0
    @State private var star3Scale: CGFloat = 0
    @State private var confettiOffset: CGFloat = -100
    @State private var glowIntensity: Double = 0
    @State private var textScale: CGFloat = 0
    
    let moveCount: Int
    let score: Int
    let onResetGame: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Darker background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .opacity(opacity)
            
            // Falling stars confetti
            ForEach(0..<15, id: \.self) { index in
                Text(["⭐", "✨", "🌟", "💫", "⭐"].randomElement() ?? "⭐")
                    .font(.title)
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: confettiOffset + CGFloat(index * 60)
                    )
                    .opacity(opacity)
            }
            
            VStack(spacing: 30) {
                // Three stars with individual animations
                HStack(spacing: 20) {
                    // Star 1
                    ZStack {
                        Text("⭐")
                            .font(.system(size: 80))
                            .blur(radius: glowIntensity)
                            .opacity(0.6)
                        
                        Text("⭐")
                            .font(.system(size: 80))
                            .scaleEffect(star1Scale)
                    }
                    
                    // Star 2
                    ZStack {
                        Text("⭐")
                            .font(.system(size: 80))
                            .blur(radius: glowIntensity)
                            .opacity(0.6)
                        
                        Text("⭐")
                            .font(.system(size: 80))
                            .scaleEffect(star2Scale)
                    }
                    
                    // Star 3
                    ZStack {
                        Text("⭐")
                            .font(.system(size: 80))
                            .blur(radius: glowIntensity)
                            .opacity(0.6)
                        
                        Text("⭐")
                            .font(.system(size: 80))
                            .scaleEffect(star3Scale)
                    }
                }
                
                // Level complete text
                VStack(spacing: 15) {
                    Text("LEVEL")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(textScale)
                    
                    Text("COMPLETE!")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(textScale)
                }
                
                // Stats
                VStack(spacing: 10) {
                    Text("⚡ \(moveCount) MOVES ⚡")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .yellow, radius: 8)
                    
                    Text("🏆 SCORE: \(score) 🏆")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .blue, radius: 8)
                }
                
                VStack(spacing: 15) {
                    // Next level button
                    Button("🌟 NEXT LEVEL 🌟") {
                        // TODO: Handle next level later
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.black)
                    .cornerRadius(25)
                    .shadow(color: .yellow, radius: 15)
                    .scaleEffect(textScale)
                    
                    // Reset/Play Again button
                    Button("🔄 PLAY AGAIN") {
                        onResetGame?() // Callback naar GameView
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(color: .blue, radius: 10)
                    .scaleEffect(textScale)
                }
            }
            .scaleEffect(scale)
        }
        .onAppear {
            // Main entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
                confettiOffset = 800
            }
            
            // Stars appear one by one
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4)) {
                star1Scale = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.7)) {
                star2Scale = 1.0
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(1.0)) {
                star3Scale = 1.0
            }
            
            // Text appears after all stars
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.3)) {
                textScale = 1.0
            }
            
            // Glow effect builds up gradually
            withAnimation(.easeOut(duration: 2.5).delay(0.4)) {
                glowIntensity = 15
            }
        }
    }
}
