import SwiftUI

enum GameScreen {
    case loadingAnimation
    case home
    case game
    case map
    case settings
}

struct ContentView: View {
    @StateObject private var levelManager = APILevelManager() // Changed to APILevelManager
    @State private var currentScreen: GameScreen = .loadingAnimation
    @State private var gameViewModel: GameViewModel?
    @State private var shouldAnimateToNextLevel: Bool = false
    
    var body: some View {
        ZStack {
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
                        shouldAnimateToNextLevel = false
                        currentScreen = .map
                    },
                    onLeaderboardTapped: {
                        levelManager.showLeaderboards()
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
                    shouldAnimateToLevel: shouldAnimateToNextLevel,
                    onAnimationComplete: {
                        shouldAnimateToNextLevel = false
                    }
                )
                
            case .game:
                if let viewModel = gameViewModel {
                    GameView(
                        viewModel: viewModel,
                        levelManager: levelManager,
                        onBackToLevelSelect: {
                            shouldAnimateToNextLevel = false
                            currentScreen = .map
                        },
                        onBackToHomeTapped: {
                            currentScreen = .home
                        },
                        onNextLevelTapped: {
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
            
            // Loading overlay when API is loading
            if levelManager.isLoading {
                LoadingOverlay()
            }
            
            // Error message overlay
            if let errorMessage = levelManager.errorMessage {
                ErrorOverlay(message: errorMessage) {
                    // Dismiss error
                    levelManager.errorMessage = nil
                }
            }
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

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
        }
    }
}

// MARK: - Error Overlay
struct ErrorOverlay: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Connection Error")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Button("OK") {
                    onDismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(30)
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
        }
    }
}

#Preview {
    ContentView()
}
