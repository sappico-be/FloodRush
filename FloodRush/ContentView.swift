//
//  ContentView.swift
//  FloodRush
//
//  Created by Kris Weytjens on 14/09/2025.
//

import SwiftUI

enum GameScreen {
    case home
    case levelSelection
    case game
    case settings
}

struct ContentView: View {
    @StateObject private var levelManager = LevelManager()
    @State private var currentScreen: GameScreen = .home
    @State private var gameViewModel: GameViewModel?
    
    var body: some View {
        switch currentScreen {
        case .home:
            HomeScreenView(
                levelManager: levelManager,
                onPlayTapped: {
                    if let nextLevel = levelManager.getNextUnlockedLevel() {
                        levelManager.selectLevel(nextLevel)
                        gameViewModel = GameViewModel(levelManager: levelManager)
                        gameViewModel?.loadLevel(nextLevel)
                        currentScreen = .game
                    }
                },
                onLevelPacksTapped: {
                    currentScreen = .levelSelection
                },
                onSettingsTapped: {
                    currentScreen = .settings
                }
            )
            
        case .levelSelection:
            LevelSelectionView(
                levelManager: levelManager,
                onLevelSelected: { level in
                    gameViewModel = GameViewModel(levelManager: levelManager)
                    gameViewModel?.loadLevel(level)
                    currentScreen = .game
                },
                onBack: {
                    currentScreen = .home
                }
            )
            
        case .game:
            if let viewModel = gameViewModel {
                GameView(
                    viewModel: viewModel,
                    levelManager: levelManager,
                    onBackToLevelSelect: {
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
}

#Preview {
    ContentView()
}
