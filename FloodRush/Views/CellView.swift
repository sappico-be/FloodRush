import SwiftUI

struct CellView: View {
    let color: Color
    let isInPlayerArea: Bool
    let animationDelay: Double // Nieuwe parameter
    @State private var animatedColor: Color
    @State private var isAnimating: Bool = false
    
    init(color: Color, isInPlayerArea: Bool, animationDelay: Double = 0) {
        self.color = color
        self.isInPlayerArea = isInPlayerArea
        self.animationDelay = animationDelay
        self._animatedColor = State(initialValue: color)
    }
    
    var body: some View {
        Rectangle()
            .fill(animatedColor)
            .overlay(
                Rectangle()
                    .stroke(isInPlayerArea ? Color.black : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .onChange(of: color) { _, newColor in
                if animationDelay > 0 {
                    // Animate color change with delay (ripple effect)
                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animatedColor = newColor
                            isAnimating = true
                        }
                        
                        withAnimation(.easeOut(duration: 0.3).delay(0.4)) {
                            isAnimating = false
                        }
                    }
                } else {
                    animatedColor = newColor
                }
            }
    }
}
