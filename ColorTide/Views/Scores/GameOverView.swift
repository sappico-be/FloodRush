import SwiftUI

struct GameOverOverlayView: View {
    let onRetry: () -> Void
    let onBackToHome: () -> Void
    
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 30) {
                Text("💔")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                
                VStack(spacing: 15) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("No lives remaining")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .scaleEffect(scale)
                
                VStack(spacing: 15) {
                    Button("Try Again") {
                        onRetry()
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    
                    Button("Home") {
                        onBackToHome()
                    }
                    .font(.headline)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
