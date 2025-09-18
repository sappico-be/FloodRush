import SwiftUI

enum GameScreen {
    case loadingAnimation
    case home
    case game
    case map
    case settings
}

struct ContentView: View {
    @StateObject private var levelManager = LevelManager()
    @State private var currentScreen: GameScreen = .loadingAnimation
    @State private var gameViewModel: GameViewModel?
    @State private var shouldAnimateToNextLevel: Bool = false // NIEUW: Track animation state
    
    var body: some View {
        switch currentScreen {
        case .loadingAnimation:
            LoadingAnimationView {
                withAnimation {
                    currentScreen = .home
                }
            }
        case .home:
            HomeScreenView(
                levelManager: levelManager,
                onPlayTapped: {
                    if let nextLevel = levelManager.getNextUnlockedLevel() {
                        startGame(with: nextLevel)
                    }
                },
                onLevelPacksTapped: {
                    shouldAnimateToNextLevel = false // Reset animation flag
                    currentScreen = .map
                },
                onLeaderboardTapped: {
                    
                },
                onSettingsTapped: {
                    currentScreen = .settings
                }
            )
        case .map:
            MapLevelsView(
                onBackTapped: {
                    currentScreen = .home
                },
                onLevelSelected: { level in
                    if levelManager.isLevelUnlocked(level.id) {
                        startGame(with: level)
                    }
                },
                levelManager: levelManager,
                shouldAnimateToLevel: shouldAnimateToNextLevel, // NIEUW: Pass animation flag
                onAnimationComplete: {
                    shouldAnimateToNextLevel = false // Reset after animation
                }
            )
            
        case .game:
            if let viewModel = gameViewModel {
                GameView(
                    viewModel: viewModel,
                    levelManager: levelManager,
                    onBackToLevelSelect: {
                        shouldAnimateToNextLevel = false // No animation when going back manually
                        currentScreen = .map
                    },
                    onBackToHomeTapped: {
                        currentScreen = .home
                    },
                    onNextLevelTapped: {
                        // NIEUW: Trigger animatie naar next level
                        shouldAnimateToNextLevel = true
                        currentScreen = .map
                    }
                )
            }
        case .settings:
            SettingsView(onBack: {
                currentScreen = .home
            })
        }
    }
    
    // Helper function om game te starten met specifiek level
    private func startGame(with level: GameLevel) {
        levelManager.selectLevel(level)
        gameViewModel = GameViewModel(levelManager: levelManager)
        gameViewModel?.loadLevel(level)
        currentScreen = .game
    }
}

#Preview {
    ContentView()
}
