import SwiftUI

struct GameView: View {
    @State private var particles: [ParticleData] = []
    @State private var scorePosition: CGPoint = CGPoint(x: 100, y: 120)
    @StateObject private var viewModel = GameViewModel(
        gridSize: 4,
        colorCount: 2,
        startPosition: GridPosition(
            row: 0,
            col: 0
        )
    )

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerView
                    .padding(.horizontal)
                
                // Grid
                GridView(
                    gameState: viewModel.gameState,
                    onCellsGained: { pointsEarned, centerPosition in
                        addScoreParticle(points: pointsEarned, from: centerPosition)
                    }
                )
                .padding(.horizontal, 30.0)
                
                // Color Picker
                ColorPickerView(
                    availableColors: Array(GameState.availableColors.prefix(viewModel.gameState.colorCount)),
                    isDisabled: viewModel.gameState.isCompleted,
                    onColorSelected: { color in
                        viewModel.makeMove(color: color) { pointsEarned, centerPosition in
                            addScoreParticle(points: pointsEarned, from: centerPosition)
                        }
                    }
                )
                .padding(.top, 10.0)
                
                Spacer()
            }
            
            // Particles overlay
            ForEach(particles, id: \.id) { particle in
                ScoreParticle(
                    points: particle.points,
                    startPosition: particle.startPosition,
                    endPosition: particle.endPosition
                ) {
                    // Remove particle when animation completes
                    particles.removeAll { $0.id == particle.id }
                }
            }
            
            // Win overlay
            if viewModel.gameState.isCompleted {
                WinOverlayView(
                    moveCount: viewModel.gameState.moveCount,
                    score: viewModel.gameState.totalScore,
                    onResetGame: {
                        viewModel.resetGame()
                    }
                )
            }
        }
    }

    var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Moves: \(viewModel.gameState.moveCount)")
                AnimatedScoreView(targetScore: viewModel.gameState.totalScore)
            }
            Spacer()
            Text("Progress: \(viewModel.gameState.currentPlayerArea.count)/\(viewModel.gameState.gridSize * viewModel.gameState.gridSize)")
        }
    }

    private func addScoreParticle(points: Int, from startPosition: CGPoint) {
        let scorePosition = CGPoint(x: 80, y: 30)
        
        // Voor grote scores, maak meerdere particles
        let particleCount = min(3, max(1, points / 100)) // 1-3 particles afhankelijk van punten
        
        for i in 0..<particleCount {
            let delayedPosition = CGPoint(
                x: startPosition.x + CGFloat.random(in: -20...20),
                y: startPosition.y + CGFloat.random(in: -20...20)
            )
            
            let particle = ParticleData(
                points: points / particleCount,
                startPosition: delayedPosition,
                endPosition: scorePosition
            )
            
            // Stagger de particles een beetje
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                particles.append(particle)
            }
        }
    }

    
}
