import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: GameViewModel
    let levelManager: LevelManager
    let onBackToLevelSelect: (() -> Void)?
    @State private var particles: [ParticleData] = []
    @State private var scorePosition: CGPoint = CGPoint(x: 100, y: 120)

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
                    targetColor: viewModel.gameState.targetColor,
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
                if levelManager.hasLivesRemaining() {
                    WinOverlayView(
                        moveCount: viewModel.gameState.moveCount,
                        score: viewModel.gameState.totalScore,
                        onResetGame: {
                            viewModel.resetGame()
                        },
                        onNextLevel: {
                            let _ = viewModel.goToNextLevel()
                        },
                        hasNextLevel: viewModel.hasNextLevel
                    )
                } else {
                    GameOverOverlayView(
                        onRetry: {
                            levelManager.resetLives()
                            viewModel.resetGame()
                        },
                        onBackToHome: {
                            levelManager.resetLives()
                            onBackToLevelSelect?()
                        }
                    )
                }
            }
        }
        .background(
            Image("ignite_grid_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    var headerView: some View {
        Group {
            HStack {
                Button {
                    onBackToLevelSelect?()
                } label: {
                    EmptyView()
                }
                .buttonStyle(
                    ImageButtonStyle(
                        normalImage: "close_button",
                        pressedImage: "close_button",
                        height: 30
                    )
                )
                
                Spacer()
                
                // Level info
                let text = "Level \(levelManager.currentLevel.levelInPack)"
                Text(text)
                    .font(.custom("FredokaOne-Regular", size: 28))
                    .foregroundStyle(.white)
                    .shadow(color: Color(red: 156/255.0, green: 56/255.0, blue: 14/255.0), radius: 0, x: 0, y: -1)
                    .shadow(color: Color(red: 156/255.0, green: 56/255.0, blue: 14/255.0), radius: 0, x: -2, y: 0)
                    .shadow(color: Color(red: 156/255.0, green: 56/255.0, blue: 14/255.0), radius: 0, x: 0, y: 2)
                    .shadow(color: Color(red: 156/255.0, green: 56/255.0, blue: 14/255.0), radius: 0, x: 2, y: 0)
                
                
                Spacer()
                
                // Placeholder voor symmetrie
                Text("Levels")
                    .opacity(0)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Moves: \(viewModel.gameState.moveCount)")
                    AnimatedScoreView(targetScore: viewModel.gameState.totalScore)
                }
                Spacer()
                
                VStack {
                    if let targetColor = viewModel.gameState.targetColor {
                        VStack(spacing: 4) {
                            Text("Target:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Circle()
                                .fill(targetColor)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(.black, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Undo button
                    Button(action: {
                        let _ = viewModel.undoLastMove()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.title2)
                            .foregroundColor(viewModel.canUndo ? .blue : .gray)
                    }
                    .disabled(!viewModel.canUndo)
                    
                    Text("Progress: \(viewModel.gameState.currentPlayerArea.count)/\(viewModel.gameState.gridSize * viewModel.gameState.gridSize)")
                        .font(.caption)
                }
            }
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

extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue
    
    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }
    
    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }
    
    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}
