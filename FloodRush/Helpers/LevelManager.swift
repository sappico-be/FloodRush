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
        let allLevels = Self.createPredefinedLevels()
        self.allLevels = allLevels
        self.currentLevel = allLevels[0]

        // Unlock alleen het eerste level
        unlockedLevels = [1]
    }

    // MARK: - Predefined Level Creation
    private static func createPredefinedLevels() -> [GameLevel] {
        var levels: [GameLevel] = []
        
        // LEVEL 1: Tutorial level - easy pattern
        levels.append(GameLevel(
            id: 1,
            gridSize: 6,
            fruitCount: 3,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 8,
            baseScore: 8000,
            predefinedGrid: [
                [.nut, .cherry, .nut, .cherry, .nut, .cherry],
                [.cherry, .nut, .cherry, .nut, .cherry, .nut],
                [.nut, .cherry, .strawberry, .strawberry, .cherry, .nut],
                [.cherry, .nut, .strawberry, .strawberry, .nut, .cherry],
                [.nut, .cherry, .nut, .cherry, .nut, .cherry],
                [.cherry, .nut, .cherry, .nut, .cherry, .nut]
            ]
        ))
        
        // LEVEL 2: Introduce strategy
        levels.append(GameLevel(
            id: 2,
            gridSize: 6,
            fruitCount: 3,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 10,
            baseScore: 8000,
            predefinedGrid: [
                [.nut, .nut, .cherry, .cherry, .nut, .nut],
                [.nut, .strawberry, .cherry, .cherry, .strawberry, .nut],
                [.strawberry, .strawberry, .nut, .nut, .strawberry, .strawberry],
                [.strawberry, .strawberry, .nut, .nut, .strawberry, .strawberry],
                [.nut, .strawberry, .cherry, .cherry, .strawberry, .nut],
                [.nut, .nut, .cherry, .cherry, .nut, .nut]
            ]
        ))
        
        // LEVEL 3: More complex pattern
        levels.append(GameLevel(
            id: 3,
            gridSize: 6,
            fruitCount: 4,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 12,
            baseScore: 8000,
            predefinedGrid: [
                [.nut, .cherry, .strawberry, .muchroom, .strawberry, .cherry],
                [.cherry, .strawberry, .muchroom, .strawberry, .cherry, .nut],
                [.strawberry, .muchroom, .nut, .cherry, .muchroom, .strawberry],
                [.muchroom, .strawberry, .cherry, .nut, .strawberry, .muchroom],
                [.strawberry, .cherry, .muchroom, .strawberry, .cherry, .nut],
                [.cherry, .nut, .strawberry, .muchroom, .nut, .cherry]
            ]
        ))
        
        // LEVEL 4: Cross pattern challenge
        levels.append(GameLevel(
            id: 4,
            gridSize: 6,
            fruitCount: 3,
            startPosition: GridPosition(row: 2, col: 2),
            targetFruit: nil,
            targetMoves: 9,
            baseScore: 8000,
            predefinedGrid: [
                [.cherry, .cherry, .nut, .nut, .strawberry, .strawberry],
                [.cherry, .cherry, .nut, .nut, .strawberry, .strawberry],
                [.strawberry, .strawberry, .nut, .nut, .cherry, .cherry],
                [.strawberry, .strawberry, .nut, .nut, .cherry, .cherry],
                [.nut, .nut, .strawberry, .strawberry, .nut, .nut],
                [.nut, .nut, .strawberry, .strawberry, .nut, .nut]
            ]
        ))
        
        // LEVEL 5: Diagonal challenge
        levels.append(GameLevel(
            id: 5,
            gridSize: 6,
            fruitCount: 4,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 11,
            baseScore: 8000,
            predefinedGrid: [
                [.nut, .cherry, .strawberry, .muchroom, .strawberry, .cherry],
                [.cherry, .nut, .cherry, .strawberry, .muchroom, .strawberry],
                [.strawberry, .cherry, .nut, .cherry, .strawberry, .muchroom],
                [.muchroom, .strawberry, .cherry, .nut, .cherry, .strawberry],
                [.strawberry, .muchroom, .strawberry, .cherry, .nut, .cherry],
                [.cherry, .strawberry, .muchroom, .strawberry, .cherry, .nut]
            ]
        ))
        
        return levels
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
    
    // MARK: - Level Creation Helper (voor development)
    func addPredefinedLevel(
        gridSize: Int,
        fruitCount: Int,
        startPosition: GridPosition,
        targetMoves: Int,
        baseScore: Int,
        grid: [[Fruit]],
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
            baseScore: baseScore,
            predefinedGrid: grid
        )
        
        allLevels.append(newLevel)
        
        if allLevels.count == 1 {
            unlockedLevels.insert(newId)
        }
    }
}
