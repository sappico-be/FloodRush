import SwiftUI
import Combine

class LevelManager: ObservableObject {
    @Published var currentLevel: GameLevel
    @Published var allLevels: [GameLevel] // Vervang availablePacks
    @Published var completedLevels: Set<Int> = [] // IDs van voltooide levels
    @Published var unlockedLevels: Set<Int> = [] // IDs van ontgrendelde levels
    @Published var totalScore: Int = 0
    @Published var totalStarsEarned: Int = 0
    @Published var levelsCompleted: Int = 0
    @Published var levelScores: [Int: Int] = [:] // levelId -> score
    @Published var levelStars: [Int: Int] = [:] // levelId -> stars
    @Published var currentLives: Int = 3
    @Published var maxLives: Int = 3
    
    init() {
        // Create all levels in sequence (60 levels total)
        var levels: [GameLevel] = []
        
        // Levels 1-20: 6x6 grids (starter difficulty)
        for levelNum in 1...20 {
            levels.append(GameLevel(
                id: levelNum,
                packId: 1, // Keep for compatibility but not used
                levelInPack: levelNum,
                gridSize: 6,
                fruitCount: min(3 + (levelNum - 1) / 5, 4),
                startPosition: GridPosition(row: 0, col: 0),
                targetFruit: nil,
                targetMoves: 8 + (levelNum - 1) / 3, // 8-14 moves
                baseScore: 8000
            ))
        }
        
        // Levels 21-40: 8x8 grids (medium difficulty)
        for levelNum in 21...40 {
            levels.append(GameLevel(
                id: levelNum,
                packId: 2, // Keep for compatibility but not used
                levelInPack: levelNum - 20,
                gridSize: 8,
                fruitCount: min(3 + (levelNum - 21) / 4, 5),
                startPosition: GridPosition(row: 1, col: 1),
                targetFruit: nil,
                targetMoves: 12 + (levelNum - 21) / 2, // 12-22 moves
                baseScore: 12000
            ))
        }
        
        // Levels 41-60: 10x10 grids (hard difficulty)
        for levelNum in 41...60 {
            levels.append(GameLevel(
                id: levelNum,
                packId: 3, // Keep for compatibility but not used
                levelInPack: levelNum - 40,
                gridSize: 10,
                fruitCount: min(4 + (levelNum - 41) / 3, 6),
                startPosition: GridPosition(row: 2, col: 2),
                targetFruit: nil,
                targetMoves: 18 + (levelNum - 41), // 18-38 moves
                baseScore: 20000
            ))
        }

        self.allLevels = levels
        self.currentLevel = levels[0]

        // Unlock alleen het eerste level
        unlockedLevels = [1]
    }
    
    func selectLevel(_ level: GameLevel) {
        currentLevel = level
    }
    
    func nextLevel() -> GameLevel? {
        guard let currentIndex = allLevels.firstIndex(where: { $0.id == currentLevel.id }) else {
            return nil
        }
        
        if currentIndex + 1 < allLevels.count {
            return allLevels[currentIndex + 1]
        }
        
        return nil // No more levels
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
            if let currentLevelIndex = allLevels.firstIndex(where: { $0.id == levelId }) {
                if currentLevelIndex + 1 < allLevels.count {
                    let nextLevel = allLevels[currentLevelIndex + 1]
                    unlockedLevels.insert(nextLevel.id)
                }
            }
        }
    }

    func getNextUnlockedLevel() -> GameLevel? {
        return allLevels.first { level in
            unlockedLevels.contains(level.id) && !completedLevels.contains(level.id)
        } ?? allLevels.first { level in
            unlockedLevels.contains(level.id)
        }
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

    func loseLife() -> Bool {
        currentLives = max(0, currentLives - 1)
        return currentLives > 0
    }
    
    func resetLives() {
        currentLives = maxLives
    }
    
    func hasLivesRemaining() -> Bool {
        return currentLives > 0
    }
    
    // Helper function to get levels for map view (chunks of 20)
    func getLevelsForMap(startIndex: Int = 0, count: Int = 20) -> [GameLevel] {
        let endIndex = min(startIndex + count, allLevels.count)
        return Array(allLevels[startIndex..<endIndex])
    }
}
