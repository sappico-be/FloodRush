import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: GameViewModel
    let levelManager: LevelManager
    let onBackToLevelSelect: (() -> Void)?
    let onBackToHomeTapped: (() -> Void)?
    let onNextLevelTapped: (() -> Void)? // NIEUW: Callback voor next level animatie
    @State private var particles: [ParticleData] = []
    @State private var scorePosition: CGPoint = CGPoint(x: 250, y: 95)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("game-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                greenLeaf
                topPanel(geometry: geometry)

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
                                // NIEUW: Trigger animatie naar next level
                                onNextLevelTapped?()
                            },
                            onBackToHomeTapped: {
                                onBackToHomeTapped?()
                            },
                            onBackToLevelsTapped: {
                                onBackToLevelSelect?()
                            },
                            hasNextLevel: viewModel.hasNextLevel,
                            targetMoves: levelManager.currentLevel.targetMoves,
                            starsEarned: calculateCurrentStars()
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
        }
        .ignoresSafeArea()
    }

    private func calculateCurrentStars() -> Int {
        let result = ScoreCalculator.calculateFinalScore(
            level: levelManager.currentLevel,
            actualMoves: viewModel.gameState.moveCount,
            cellsGainedPerMove: viewModel.gameState.cellsGainedPerMove ?? []
        )
        return result.stars
    }

    private func topPanel(geometry: GeometryProxy) -> some View {
        VStack{
            HStack {
                Spacer()
                ZStack {
                    Image("top-panel-safe-area")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: geometry.size.width - 25
                        )
                        .clipped()
                    
                    HStack {
                        ZStack(alignment: .leading) {
                            Image("lives-info")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40.0)
                                .clipped()
                            Image("move-count")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40.0)
                                .clipped()
                            Text("\(viewModel.gameState.moveCount)")
                                .font(.custom("helsinki", size: 23.0))
                                .foregroundStyle(.white)
                                .padding(.trailing, 10.0)
                                .padding(.leading, 40)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(maxWidth: 100)
                        }
                        
                        ZStack {
                            Image("points-block")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40.0)
                                .clipped()
                            AnimatedScoreView(targetScore: viewModel.gameState.totalScore)
                                .frame(maxWidth: 100)
                        }
                        
                        Button {
                            
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(
                            ImageButtonStyle(
                                normalImage: "pause-button",
                                pressedImage: "pause-button",
                                height: 40.0
                            )
                        )

                    }
                    .padding(.top, 30.0)
                    .padding(.trailing, 20.0)
                }
            }

            if !viewModel.gameState.isCompleted {
                playArea(geometry: geometry)
                    .padding(.top, 20.0)
                    .padding(.horizontal, 20.0)
            }

            
        }
        .frame(maxWidth: .infinity)
    }

    private func playArea(geometry: GeometryProxy) -> some View {
        VStack {
            ZStack(alignment: .top) {
                Image("play-area")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        maxWidth: geometry.size.width
                    )
                    .clipped()
                
                playAreaContent(geometry: geometry)
            }
            
            // Color Picker
            ColorPickerView(
                availableFruits: Array(GameState.availableFruits.prefix(viewModel.gameState.fruitCount)),
                targetFruit: viewModel.gameState.targetFruit,
                isDisabled: viewModel.gameState.isCompleted,
                onFruitSelected: { fruit in
                    viewModel.makeMove(fruit: fruit) { pointsEarned, centerPosition in
                        addScoreParticle(points: pointsEarned, from: centerPosition)
                    }
                }
            )
            .frame(maxHeight: 70.0)
            
            Spacer()
            
            HStack {
                Button {
                    onBackToHomeTapped?()
                } label: {
                    EmptyView()
                }
                .buttonStyle(
                    ImageButtonStyle(
                        normalImage: "exit-button",
                        pressedImage: "exit-button",
                        height: 60.0
                    )
                )
                
                Spacer()
            }
            .padding(.bottom, 20.0)
        }
        .frame(maxWidth: .infinity)
    }

    private func playAreaContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 10.0) {
            HStack {
                Color.clear
                    .frame(width: 40.0, height: 40.0)
                Spacer()
                Text("Level \(levelManager.currentLevel.id)")
                    .font(.custom("helsinki", size: 30.0))
                    .foregroundStyle(.white)
                Spacer()

                Button {
                    if viewModel.canUndo {
                        let _ = viewModel.undoLastMove()
                    }
                } label: {
                    EmptyView()
                }
                .buttonStyle(
                    ImageButtonStyle(
                        normalImage: "rerty-button",
                        pressedImage: "rerty-button",
                        height: 40.0
                    )
                )
                .disabled(!viewModel.canUndo)
            }
            GridView(
                gameState: viewModel.gameState
            )
            .padding(.bottom, 20.0)
            .padding(.top, 15.0)
        }
        .padding(.top, 25.0)
        .padding(.horizontal, 15.0)
    }

    private var greenLeaf: some View {
        VStack {
            Spacer()
            Image("green-leaf")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(
                    maxHeight: 250
                )
                .clipped()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addScoreParticle(points: Int, from startPosition: CGPoint) {
        let particleCount = min(3, max(1, points / 100))
        
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

#Preview {
    GameView(
        viewModel: GameViewModel(levelManager: LevelManager()),
        levelManager: LevelManager(),
        onBackToLevelSelect: {},
        onBackToHomeTapped: {},
        onNextLevelTapped: {}
    )
}
