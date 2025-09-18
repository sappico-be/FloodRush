import SwiftUI
import Combine

class LevelManager: ObservableObject {
    @Published var currentLevel: GameLevel
    @Published var allLevels: [GameLevel]
    @Published var completedLevels: Set<Int> = []
    @Published var unlockedLevels: Set<Int> = []
    @Published var totalScore: Int = 0
    @Published var totalStarsEarned: Int = 0
    @Published var levelsCompleted: Int = 0
    @Published var levelScores: [Int: Int] = [:]
    @Published var levelStars: [Int: Int] = [:]
    @Published var currentLives: Int = 3
    @Published var maxLives: Int = 3
    
    init() {
        // Create all levels in sequence (60 levels total)
        var levels: [GameLevel] = []
        
        // Levels 1-20: 6x6 grids (starter difficulty)
        for levelNum in 1...20 {
            levels.append(GameLevel(
                id: levelNum,
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
        
        return nil
    }

    func getLevel(byId id: Int) -> GameLevel? {
        return allLevels.first { $0.id == id }
    }

    func completeLevel(_ levelId: Int, withScore score: Int, stars: Int) {
        let wasAlreadyCompleted = completedLevels.contains(levelId)
        
        if !wasAlreadyCompleted {
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
        
        // Unlock next level
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

    func getScoreForLevel(_ levelId: Int) -> Int {
        return levelScores[levelId] ?? 0
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
        guard startIndex < allLevels.count && startIndex >= 0 else { return [] }
        return Array(allLevels[startIndex..<endIndex])
    }

    func getTotalLevelCount() -> Int {
        return allLevels.count
    }
    
    // MARK: - Easy Level Addition
    func addLevel(
        gridSize: Int,
        fruitCount: Int,
        startPosition: GridPosition,
        targetMoves: Int,
        baseScore: Int,
        targetFruit: Fruit? = nil
    ) {
        let newId = (allLevels.last?.id ?? 0) + 1
        let newLevel = GameLevel(
            id: newId,
            gridSize: gridSize,
            fruitCount: fruitCount,
            startPosition: startPosition,
            targetFruit: targetFruit,
            targetMoves: targetMoves,
            baseScore: baseScore
        )
        
        allLevels.append(newLevel)
        
        // If this is the first level, unlock it
        if allLevels.count == 1 {
            unlockedLevels.insert(newId)
        }
    }
}
