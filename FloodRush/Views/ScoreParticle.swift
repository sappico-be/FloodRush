import SwiftUI

struct ScoreParticle: View {
    let points: Int
    let startPosition: CGPoint
    let endPosition: CGPoint
    @State private var position: CGPoint
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    
    init(points: Int, startPosition: CGPoint, endPosition: CGPoint) {
        self.points = points
        self.startPosition = startPosition
        self.endPosition = endPosition
        self._position = State(initialValue: startPosition)
    }
    
    var body: some View {
        Text("+\(points)")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.yellow)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    position = endPosition
                    scale = 0.8
                }
                
                withAnimation(.easeIn(duration: 0.3).delay(0.9)) {
                    opacity = 0
                }
            }
    }
}
