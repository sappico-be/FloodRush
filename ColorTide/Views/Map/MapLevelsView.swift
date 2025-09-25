import SwiftUI

struct MapLevelsView: View {
    let onBackTapped: () -> Void
    let onLevelSelected: (GameLevel) -> Void
    @ObservedObject var levelManager: APILevelManager
    let shouldAnimateToLevel: Bool // NIEUW: Should we animate to next level?
    let onAnimationComplete: () -> Void // NIEUW: Callback when animation is done
    
    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    @State private var currentPage: Int = 0
    @State private var playerPosition: CGPoint = .zero
    @State private var showPlayer: Bool = false
    @State private var isAnimating: Bool = false
    
    // Level posities als percentage van de kaart (x: 0-1, y: 0-1)
    private let levelPositions: [(x: Double, y: Double)] = [
        (0.15, 1.24), (0.34, 1.17), (0.66, 1.17), (0.87, 1.10), (0.65, 1.045),
        (0.37, 1.04), (0.62, 0.95), (0.35, 0.93), (0.27, 0.85), (0.5, 0.77),
        (0.46, 0.69), (0.20, 0.67), (0.7, 0.645), (0.87, 0.57), (0.7, 0.535),
        (0.40, 0.53), (0.55, 0.47), (0.7, 0.43), (0.25, 0.4), (0.35, 0.3)
    ]
    
    private var currentPageLevels: [GameLevel] {
        let startIdx = currentPage * 20
        return levelManager.getLevelsForMap(startIndex: startIdx, count: 20)
    }
    
    private var totalPages: Int {
        return (levelManager.getTotalLevelCount() + 20 - 1) / 20
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
                                levelButtonsOverlay(in: geometry.size)
                            }
                            .overlay {
                                // NIEUW: Player sprite overlay
                                if showPlayer {
                                    playerSprite
                                        .position(playerPosition)
                                        .animation(.easeInOut(duration: 2.0), value: playerPosition)
                                }
                            }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                .scrollPosition($scrollPosition)
                .onAppear {
                    scrollPosition.scrollTo(edge: .bottom)
                    
                    // NIEUW: Start animation if needed
                    if shouldAnimateToLevel {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            startPlayerAnimation(in: geometry.size)
                        }
                    }
                }
                
                // Navigation controls
                navigationControls
            }
        }
        .ignoresSafeArea()
    }
    
    // NIEUW: Player sprite
    private var playerSprite: some View {
        ZStack {
            // Player character - je kunt dit vervangen met je eigen sprite
            Image(systemName: "figure.walk.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                )
                .shadow(radius: 3)
            
            // Optional: Trail effect
            if isAnimating {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.0 : 0.8)
                    .animation(.easeOut(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            }
        }
    }
    
    // NIEUW: Start player animation to next level
    private func startPlayerAnimation(in size: CGSize) {
        guard let currentLevel = getCurrentLevel(),
              let nextLevel = levelManager.nextLevel() else {
            onAnimationComplete()
            return
        }
        
        // Find positions of current and next level
        let currentLevelIndex = currentLevel.id - 1 - (currentPage * 20)
        let nextLevelIndex = nextLevel.id - 1 - (currentPage * 20)
        
        guard currentLevelIndex < levelPositions.count,
              nextLevelIndex < levelPositions.count else {
            onAnimationComplete()
            return
        }
        
        let currentPos = levelPositions[currentLevelIndex]
        let nextPos = levelPositions[nextLevelIndex]
        
        // Set initial position
        playerPosition = CGPoint(
            x: size.width * currentPos.x,
            y: size.height * currentPos.y
        )
        
        // Show player and start animation
        showPlayer = true
        isAnimating = true
        
        // Play sound
        SoundManager.shared.playSuccessSound()
        
        // Animate to next level
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 2.0)) {
                playerPosition = CGPoint(
                    x: size.width * nextPos.x,
                    y: size.height * nextPos.y
                )
            }
        }
        
        // Complete animation and auto-select next level
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            isAnimating = false
            
            // Flash effect on arrival
            withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true)) {
                // You could add a flash effect here
            }
            
            // Play arrival sound
            SoundManager.shared.playLevelCompleteSound()
            SoundManager.shared.successHaptic()
            
            // Auto-select next level after a short pause
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showPlayer = false
                levelManager.selectLevel(nextLevel)
                onLevelSelected(nextLevel)
                onAnimationComplete()
            }
        }
    }
    
    // NIEUW: Get current level for animation
    private func getCurrentLevel() -> GameLevel? {
        return levelManager.allLevels.first { $0.id == levelManager.currentLevel.id }
    }
    
    private var navigationControls: some View {
        VStack {
            HStack {
                // Back button - disabled during animation
                Button {
                    if !isAnimating {
                        SoundManager.shared.playButtonTapSound()
                        onBackTapped()
                    }
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
                .disabled(isAnimating)
                .opacity(isAnimating ? 0.5 : 1.0)
                
                Spacer()
                
                // Page info
                Text("Levels \(currentPage * 20 + 1) - \(min((currentPage + 1) * 20, levelManager.getTotalLevelCount()))")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)
            }
            .padding(.top, 60.0)
            .padding(.horizontal, 20.0)
            
            Spacer()
            
            // Page navigation buttons - disabled during animation
            if totalPages > 1 {
                HStack(spacing: 20) {
                    // Previous page
                    if currentPage > 0 {
                        Button {
                            if !isAnimating {
                                SoundManager.shared.playButtonTapSound()
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(isAnimating)
                        .opacity(isAnimating ? 0.5 : 1.0)
                    }
                    
                    Spacer()
                    
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<totalPages, id: \.self) { page in
                            Circle()
                                .fill(page == currentPage ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 10, height: 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Next page
                    if currentPage < totalPages - 1 {
                        Button {
                            if !isAnimating {
                                SoundManager.shared.playButtonTapSound()
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(isAnimating)
                        .opacity(isAnimating ? 0.5 : 1.0)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func levelButtonsOverlay(in size: CGSize) -> some View {
        ZStack {
            ForEach(Array(currentPageLevels.enumerated()), id: \.element.id) { index, level in
                if index < levelPositions.count {
                    let position = levelPositions[index]
                    
                    MapLevelButton(
                        level: level,
                        levelManager: levelManager,
                        isDisabled: isAnimating, // NIEUW: Disable during animation
                        onTapped: {
                            if !isAnimating {
                                SoundManager.shared.playButtonTapSound()
                                SoundManager.shared.selectionHaptic()
                                onLevelSelected(level)
                            }
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
    @ObservedObject var levelManager: APILevelManager
    let isDisabled: Bool // NIEUW: External disable state
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
            if isUnlocked && !isDisabled {
                onTapped()
            }
        }) {
            ZStack {
                Image(isUnlocked ? "pointer-enabled" : "pointer-disabled")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                
                VStack(spacing: 0) {
                    // Sterren in boog vorm
                    ZStack {
                        ForEach(0..<3, id: \.self) { starIndex in
                            let angle = (Double(starIndex) - 1.0) * 35.0
                            let radius: CGFloat = 20
                            let xOffset = sin(angle * .pi / 180) * radius
                            let yOffset = -cos(angle * .pi / 180) * radius
                            
                            Image(starIndex < starsEarned ? "star-big-icon" : "empty-star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                                .shadow(color: .black.opacity(0.7), radius: 1)
                                .offset(x: xOffset, y: yOffset)
                                .opacity(isUnlocked ? 1.0 : 0.6)
                        }
                    }
                    .frame(height: 25)
                    
                    // Level nummer
                    Text("\(level.id)")
                        .font(.custom("helsinki", size: 30))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 1)
                        .padding(.top, -25)
                        .padding(.bottom, 40)
                        .padding(.trailing, 5)
                }
                .padding(.top, 8)
            }
        }
        .disabled(!isUnlocked || isDisabled)
        .scaleEffect(isUnlocked && !isDisabled ? 1.0 : 0.85)
        .opacity(isDisabled ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

#Preview {
    MapLevelsView(
        onBackTapped: {},
        onLevelSelected: { _ in },
        levelManager: APILevelManager(),
        shouldAnimateToLevel: false,
        onAnimationComplete: {}
    )
}
