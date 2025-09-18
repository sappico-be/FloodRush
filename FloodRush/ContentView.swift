//
//  ContentView.swift
//  FloodRush
//
//  Created by Kris Weytjens on 14/09/2025.
//

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
    
    var body: some View {
        switch currentScreen {
        case .loadingAnimation:
            LoadingAnimationView {
                // Callback wanneer animatie voltooid is
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
                levelManager: levelManager
            )
            
        case .game:
            if let viewModel = gameViewModel {
                GameView(
                    viewModel: viewModel,
                    levelManager: levelManager,
                    onBackToLevelSelect: {
                        currentScreen = .map
                    },
                    onBackToHomeTapped: {
                        currentScreen = .home
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
