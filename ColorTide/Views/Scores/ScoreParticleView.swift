import SwiftUI

struct ScoreParticle: View {
    @State private var particleData: ParticleData
    let onComplete: () -> Void
    
    init(points: Int, startPosition: CGPoint, endPosition: CGPoint, onComplete: @escaping () -> Void) {
        self._particleData = State(initialValue: ParticleData(points: points, startPosition: startPosition, endPosition: endPosition))
        self.onComplete = onComplete
    }
    
    var body: some View {
        Text("+\(particleData.points)")
            .font(.largeTitle) // Groter font
            .fontWeight(.black) // Dikker weight
            .foregroundColor(.yellow)
            .shadow(color: .orange, radius: 8) // Meer glow
            .scaleEffect(particleData.scale)
            .opacity(particleData.opacity)
            .position(particleData.currentPosition)
            .onAppear {
                animateParticle()
            }
    }
    
    private func animateParticle() {
        // Phase 1: DRAMATIC pop-in
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            particleData.scale = 2.0 // Nog groter!
        }
        
        // Phase 2: Settle en begin vlucht
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            particleData.scale = 1.5
        }
        
        // Phase 3: Fly naar score
        withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
            particleData.currentPosition = particleData.endPosition
            particleData.scale = 0.8
        }
        
        // Phase 4: Fade out
        withAnimation(.easeIn(duration: 0.3).delay(1.2)) {
            particleData.opacity = 0
        }
        
        // Cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            onComplete()
        }
    }
}
