import SwiftUI
import Combine

class LevelManager: ObservableObject {
    @Published var currentPack: LevelPack
    @Published var currentLevel: GameLevel
    @Published var availablePacks: [LevelPack]
    @Published var completedLevels: Set<Int> = [] // IDs van voltooide levels
    @Published var unlockedLevels: Set<Int> = [] // IDs van ontgrendelde levels
    @Published var totalScore: Int = 0
    @Published var totalStarsEarned: Int = 0
    @Published var levelsCompleted: Int = 0
    @Published var levelScores: [Int: Int] = [:] // levelId -> score
    @Published var levelStars: [Int: Int] = [:] // levelId -> stars
    
    init() {
        // Pack 1: Starter Pack (6x6 grids)
        let starterLevels = (1...20).map { levelNum in
            GameLevel(
                id: levelNum,
                packId: 1,
                levelInPack: levelNum,
                gridSize: 6,
                colorCount: min(3 + (levelNum - 1) / 5, 4), // Start 3 kleuren, naar 4
                startPosition: GridPosition(row: 0, col: 0),
                targetStars: [100, 300, 500]
            )
        }
        
        // Pack 2: Explorer Pack (8x8 grids)
        let explorerLevels = (1...20).map { levelNum in
            GameLevel(
                id: 20 + levelNum,
                packId: 2,
                levelInPack: levelNum,
                gridSize: 8,
                colorCount: min(3 + (levelNum - 1) / 4, 5), // Start 3, naar 5
                startPosition: GridPosition(row: 1, col: 1), // Andere start positie
                targetStars: [200, 600, 1000]
            )
        }
        
        // Pack 3: Master Pack (10x10 grids)
        let masterLevels = (1...20).map { levelNum in
            GameLevel(
                id: 40 + levelNum,
                packId: 3,
                levelInPack: levelNum,
                gridSize: 10,
                colorCount: min(4 + (levelNum - 1) / 3, 6), // Start 4, naar 6
                startPosition: GridPosition(row: 2, col: 2),
                targetStars: [500, 1200, 2000]
            )
        }

        let availablePacks = [
            LevelPack(id: 1, name: "Starter Pack", emoji: "🌱", baseGridSize: 6, baseColorCount: 3, levels: starterLevels, isUnlocked: true),
            LevelPack(id: 2, name: "Explorer Pack", emoji: "🏕️", baseGridSize: 8, baseColorCount: 4, levels: explorerLevels, isUnlocked: false),
            LevelPack(id: 3, name: "Master Pack", emoji: "⚡", baseGridSize: 10, baseColorCount: 5, levels: masterLevels, isUnlocked: false)
        ]

        self.availablePacks = availablePacks
        self.currentPack = availablePacks[0]
        self.currentLevel = availablePacks[0].levels[0]

        // Unlock eerste level van elke pack
        unlockedLevels.insert(1) // Starter pack level 1
        unlockedLevels.insert(21) // Explorer pack level 1 (als pack unlocked is)
        unlockedLevels.insert(41) // Master pack level 1 (als pack unlocked is)
        
        // Voor nu: unlock alleen eerste level van eerste pack
        unlockedLevels = [1]
    }
    
    func selectLevel(_ level: GameLevel) {
        currentLevel = level
        currentPack = availablePacks.first { $0.id == level.packId } ?? currentPack
    }
    
    func nextLevel() -> GameLevel? {
        let currentIndex = currentPack.levels.firstIndex { $0.id == currentLevel.id } ?? 0
        
        if currentIndex + 1 < currentPack.levels.count {
            // Volgende level in huidige pack
            return currentPack.levels[currentIndex + 1]
        } else {
            // Volgende pack
            let nextPackIndex = availablePacks.firstIndex { $0.id == currentPack.id } ?? 0
            if nextPackIndex + 1 < availablePacks.count {
                return availablePacks[nextPackIndex + 1].levels.first
            }
        }
        
        return nil
    }

    func completeLevel(_ levelId: Int, withScore score: Int, stars: Int) {
        let wasAlreadyCompleted = completedLevels.contains(levelId)
        
        if !wasAlreadyCompleted {
            // Nieuwe completion
            completedLevels.insert(levelId)
            totalScore += score
            totalStarsEarned += stars
            levelsCompleted += 1
            levelScores[levelId] = score
            levelStars[levelId] = stars
        } else {
            // Level opnieuw gespeeld - update als score beter is
            let previousScore = levelScores[levelId] ?? 0
            let previousStars = levelStars[levelId] ?? 0
            
            if score > previousScore {
                totalScore += (score - previousScore)
                levelScores[levelId] = score
            }
            
            if stars > previousStars {
                totalStarsEarned += (stars - previousStars)
                levelStars[levelId] = stars
            }
        }
        
        // Unlock next level logic
        if !wasAlreadyCompleted {
            if let currentLevelIndex = availablePacks.flatMap({ $0.levels }).firstIndex(where: { $0.id == levelId }) {
                let allLevels = availablePacks.flatMap({ $0.levels })
                if currentLevelIndex + 1 < allLevels.count {
                    let nextLevel = allLevels[currentLevelIndex + 1]
                    unlockedLevels.insert(nextLevel.id)
                }
            }
            
            updatePackUnlockStatus()
        }
    }

    private func updatePackUnlockStatus() {
        // Update pack unlock status gebaseerd op voltooide levels
        for pack in availablePacks {
            let packLevels = Set(pack.levels.map { $0.id })
            let completedInPack = completedLevels.intersection(packLevels)
            
            // Als alle levels in een pack voltooid zijn, unlock volgende pack
            if completedInPack.count == pack.levels.count {
                if let nextPackIndex = availablePacks.firstIndex(where: { $0.id == pack.id + 1 }) {
                    let nextPack = availablePacks[nextPackIndex]
                    unlockedLevels.insert(nextPack.levels[0].id)
                }
            }
        }
    }

    func getNextUnlockedLevel() -> GameLevel? {
        let allLevels = availablePacks.flatMap({ $0.levels })
        return allLevels.first { level in
            unlockedLevels.contains(level.id) && !completedLevels.contains(level.id)
        } ?? allLevels.first { level in
            unlockedLevels.contains(level.id)
        }
    }

    func getCurrentProgressPack() -> LevelPack? {
        if let nextLevel = getNextUnlockedLevel() {
            return availablePacks.first { $0.id == nextLevel.packId }
        }
        return availablePacks.first
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }
    
    func isLevelCompleted(_ levelId: Int) -> Bool {
        return completedLevels.contains(levelId)
    }
    
    func getStarsForLevel(_ levelId: Int) -> Int {
        return levelStars[levelId] ?? 0
    }
}
