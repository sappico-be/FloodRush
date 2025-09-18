import SwiftUI

struct LoadingAnimationView: View {
    let onAnimationComplete: () -> Void
    
    @State private var logoPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var logoScale: CGFloat = 1.0
    @State private var logoRotation: Double = 0
    @State private var logoSkew: Double = 0
    @State private var glowIntensity: Double = 0
    @State private var screenCenter: CGPoint = .zero
    @State private var finalPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Achtergrond
                Image("intro_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .scaleEffect(1.1 + glowIntensity * 0.05) // Subtle background pulse
                
                // Glow effect achter logo
                Image("logo_forest_run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 128)
                    .scaleEffect(logoScale * 1.2)
                    .blur(radius: 20)
                    .opacity(glowIntensity * 0.7)
                    .foregroundColor(.yellow)
                    .position(logoPosition)
                
                // Hoofd logo met alle effecten
                Image("logo_forest_run")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 128)
                    .scaleEffect(logoScale)
                    .rotationEffect(.degrees(logoRotation))
                    .rotation3DEffect(
                        .degrees(logoSkew),
                        axis: (x: 1, y: 0, z: 0)
                    )
                    .position(logoPosition)
                    .shadow(color: .white, radius: glowIntensity * 10)
            }
            .onAppear {
                // Calculate positions based on screen size
                DispatchQueue.main.async {
                    setupPositions(geometry: geometry)
                    startLogoAnimation()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func setupPositions(geometry: GeometryProxy) {
        screenCenter = CGPoint(
            x: geometry.size.width / 2,
            y: geometry.size.height / 2
        )
        
        finalPosition = CGPoint(
            x: geometry.size.width / 2,
            y: geometry.size.height * 0.25 // 25% from top (header position)
        )
        
        // Set starting position (center of screen)
        logoPosition = screenCenter
    }
    
    private func startLogoAnimation() {
        dimensionWarp()
    }

    private func dimensionWarp() {
        // Phase 1: Shrink to nothing
        withAnimation(.easeIn(duration: 0.8)) {
            logoScale = 0.01
            logoRotation = 180
            glowIntensity = 1.0
        }
        
        // Phase 2: Warp through dimensions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            logoPosition = finalPosition
            
            // Crazy warp animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
                logoScale = 1.8
                logoRotation = -360
            }
            
            // 3D effects
            withAnimation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true)) {
                logoSkew = 45
            }
            
            // Reality stabilizes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    logoScale = 1.4
                    logoRotation = 0
                    logoSkew = 0
                    glowIntensity = 0
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            onAnimationComplete()
        }
    }
}
