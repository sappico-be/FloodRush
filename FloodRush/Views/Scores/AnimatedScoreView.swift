import SwiftUI

struct AnimatedScoreView: View {
    let targetScore: Int
    @State private var displayScore: Int = 0
    
    var body: some View {
        Text("Score: \(displayScore)")
            .onChange(of: targetScore) { _, newScore in
                animateScore(to: newScore)
            }
            .onAppear {
                displayScore = targetScore
            }
    }
    
    private func animateScore(to newScore: Int) {
        guard newScore != displayScore else { return }
        
        let difference = newScore - displayScore
        let duration: Double = 0.8
        let steps = max(10, abs(difference) / 20)
        let increment = difference / steps
        let timeInterval = duration / Double(steps)
        
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { timer in
            currentStep += 1
            
            if currentStep >= steps {
                displayScore = newScore
                timer.invalidate()
            } else {
                displayScore += increment
            }
        }
    }
}
