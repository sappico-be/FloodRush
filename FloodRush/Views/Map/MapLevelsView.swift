import SwiftUI

struct MapLevelsView: View {
    let onBackTapped: () -> Void
    let onLevelSelected: (GameLevel) -> Void
    @ObservedObject var levelManager: LevelManager // Voor toegang tot save data
    let startIndex: Int = 0 // Welke levels te tonen (0, 20, 40, etc.)
    let levelCount: Int = 20 // Hoeveel levels te tonen (default 20)
    
    @State private var scrollPosition = ScrollPosition(edge: .bottom)
    @State private var currentPage: Int = 0
    
    // Level posities als percentage van de kaart (x: 0-1, y: 0-1)
    private let levelPositions: [(x: Double, y: Double)] = [
        (0.15, 1.24), (0.34, 1.17), (0.7, 0.82), (0.2, 0.75), (0.8, 0.68),
        (0.4, 0.62), (0.6, 0.55), (0.25, 0.48), (0.75, 0.42), (0.5, 0.35),
        (0.35, 0.28), (0.65, 0.22), (0.2, 0.18), (0.8, 0.15), (0.45, 0.12),
        (0.55, 0.09), (0.3, 0.06), (0.7, 0.04), (0.4, 0.02), (0.6, 0.01)
    ]
    
    private var currentPageLevels: [GameLevel] {
        let startIdx = currentPage * levelCount
        return levelManager.getLevelsForMap(startIndex: startIdx, count: levelCount)
    }
    
    private var totalPages: Int {
        return (levelManager.getTotalLevelCount() + levelCount - 1) / levelCount
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

                // Navigation controls
                VStack {
                    HStack {
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
                        
                        Spacer()
                        
                        // Page info
                        Text("Levels \(currentPage * levelCount + 1) - \(min((currentPage + 1) * levelCount, levelManager.getTotalLevelCount()))")
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
                    
                    // Page navigation buttons
                    if totalPages > 1 {
                        HStack(spacing: 20) {
                            // Previous page
                            if currentPage > 0 {
                                Button {
                                    SoundManager.shared.playButtonTapSound()
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                } label: {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
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
                                    SoundManager.shared.playButtonTapSound()
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } label: {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func levelButtonsOverlay(in size: CGSize) -> some View {
        ZStack {
            ForEach(Array(currentPageLevels.enumerated()), id: \.element.id) { index, level in
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
        .disabled(!isUnlocked)
        .scaleEffect(isUnlocked ? 1.0 : 0.85)
        .animation(.easeInOut(duration: 0.2), value: isUnlocked)
    }
}

#Preview {
    MapLevelsView(
        onBackTapped: {},
        onLevelSelected: { _ in },
        levelManager: LevelManager()
    )
}
