import SwiftUI

struct MapLevelsView: View {
    let onBackTapped: () -> Void
    let onLevelSelected: (GameLevel) -> Void
    @ObservedObject var levelManager: LevelManager // Voor toegang tot save data
    let startIndex: Int // Welke levels te tonen (0, 20, 40, etc.)
    let levelCount: Int // Hoeveel levels te tonen (default 20)
    
    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    
    // Level posities als percentage van de kaart (x: 0-1, y: 0-1)
    // Voor 20 levels per map
    private let levelPositions: [(x: Double, y: Double)] = [
        (0.15, 1.24),   // Level 1 - onderaan midden
        (0.34, 1.17),   // Level 2 - links omhoog
        (0.7, 0.82),   // Level 3 - rechts omhoog
        (0.2, 0.75),   // Level 4 - ver links
        (0.8, 0.68),   // Level 5 - ver rechts
        (0.4, 0.62),   // Level 6 - links van midden
        (0.6, 0.55),   // Level 7 - rechts van midden
        (0.25, 0.48),  // Level 8 - links
        (0.75, 0.42),  // Level 9 - rechts
        (0.5, 0.35),   // Level 10 - midden
        (0.35, 0.28),  // Level 11 - links
        (0.65, 0.22),  // Level 12 - rechts
        (0.2, 0.18),   // Level 13 - ver links
        (0.8, 0.15),   // Level 14 - ver rechts
        (0.45, 0.12),  // Level 15 - links van midden boven
        (0.55, 0.09),  // Level 16 - rechts van midden boven
        (0.3, 0.06),   // Level 17 - links boven
        (0.7, 0.04),   // Level 18 - rechts boven
        (0.4, 0.02),   // Level 19 - links bovenaan
        (0.6, 0.01),   // Level 20 - rechts bovenaan
    ]
    
    // Computed property voor levels om te tonen
    private var levelsToShow: [GameLevel] {
        levelManager.getLevelsForMap(startIndex: startIndex, count: levelCount)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Background map met scroll
                ScrollView {
                    ZStack {
                        Image("map-background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width)
                            .clipped()
                            .overlay {
                                // Level buttons over de kaart
                                levelButtonsOverlay(in: geometry.size)
                            }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .scrollPosition($scrollPosition)
                .onAppear {
                    scrollPosition.scrollTo(edge: .bottom)
                }

                // Back button
                Button {
                    SoundManager.shared.playButtonTapSound()
                    onBackTapped()
                } label: {
                    EmptyView()
                }
                .buttonStyle(
                    ImageButtonStyle(
                        normalImage: "back-button-orange",
                        pressedImage: "back-button-orange",
                        height: 60.0
                    )
                )
                .padding(.top, 60.0)
                .padding(.horizontal, 20.0)
            }
        }
        .ignoresSafeArea()
    }
    
    private func levelButtonsOverlay(in size: CGSize) -> some View {
        ZStack {
            ForEach(Array(levelsToShow.enumerated()), id: \.element.id) { index, level in
                // Zorg dat we niet buiten de posities array gaan
                if index < levelPositions.count {
                    let position = levelPositions[index]
                    
                    MapLevelButton(
                        level: level,
                        levelManager: levelManager,
                        onTapped: {
                            SoundManager.shared.playButtonTapSound()
                            SoundManager.shared.selectionHaptic()
                            onLevelSelected(level)
                        }
                    )
                    .position(
                        x: size.width * position.x,
                        y: size.height * position.y
                    )
                }
            }
        }
    }
}

struct MapLevelButton: View {
    let level: GameLevel
    @ObservedObject var levelManager: LevelManager
    let onTapped: () -> Void
    
    private var isUnlocked: Bool {
        levelManager.isLevelUnlocked(level.id)
    }
    
    private var isCompleted: Bool {
        levelManager.isLevelCompleted(level.id)
    }
    
    private var starsEarned: Int {
        levelManager.getStarsForLevel(level.id)
    }
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                onTapped()
            }
        }) {
            ZStack {
                // Pointer image gebaseerd op unlock status
                Image(isUnlocked ? "pointer-enabled" : "pointer-disabled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                
                VStack(spacing: 0) {
                    // Sterren - altijd 3 sterren in een ovaal/boog vorm
                    ZStack {
                        ForEach(0..<3, id: \.self) { starIndex in
                            let angle = (Double(starIndex) - 1.0) * 35.0 // -35°, 0°, +35° voor meer spreiding
                            let radius: CGFloat = 20 // Meer afstand van center
                            let xOffset = sin(angle * .pi / 180) * radius
                            let yOffset = -cos(angle * .pi / 180) * radius * 1 // 0.3 voor ovaal vorm
                            
                            if isUnlocked {
                                // Voor unlocked levels: volle sterren of empty sterren
                                Image(starIndex < starsEarned ? "star-big-icon" : "empty-star")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14) // Groter: van 10 naar 14
                                    .shadow(color: .black.opacity(0.7), radius: 1)
                                    .offset(x: xOffset, y: yOffset)
                            } else {
                                // Voor locked levels: altijd empty sterren
                                Image("empty-star")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 14, height: 14) // Groter: van 10 naar 14
//                                    .opacity(0.6) // Iets transparanter voor locked levels
                                    .shadow(color: .black.opacity(0.5), radius: 1)
                                    .offset(x: xOffset, y: yOffset)
                            }
                        }
                    }
                    .frame(height: 25) // Meer hoogte voor grotere sterren en spreiding
                    .padding(.bottom, 0)
                    
                    // Level nummer (altijd tonen)
                    Text("\(level.levelInPack)")
                        .font(.custom("helsinki", size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1)
                        .padding(.top, -25)
                        .padding(.bottom, 40)
                        .padding(.trailing, 5)
                }
                .padding(.top, 8) // Positioneer content in het midden van de pointer
            
            }
        }
        .disabled(!isUnlocked)
        .scaleEffect(isUnlocked ? 1.0 : 0.85)
//        .opacity(isUnlocked ? 1.0 : 0.7)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

#Preview {
    MapLevelsView(
        onBackTapped: {},
        onLevelSelected: { _ in },
        levelManager: LevelManager(),
        startIndex: 0,
        levelCount: 20
    )
}
