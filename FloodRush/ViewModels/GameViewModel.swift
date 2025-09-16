import SwiftUI
import Combine
import AVFoundation

class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState
    let levelManager: LevelManager

    init(levelManager: LevelManager) {
        self.levelManager = levelManager
        let level = levelManager.currentLevel
        
        self.gameState = GameState(
            gridSize: level.gridSize,
            fruitCount: level.fruitCount,
            startPosition: level.startPosition,
            targetFruit: level.targetFruit,
            grid: Array(repeating: Array(repeating: Fruit.nut, count: level.gridSize), count: level.gridSize),
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0,
            gameHistory: []
        )
        
        initializeGame()
    }

    func loadLevel(_ level: GameLevel) {
        gameState = GameState(
            gridSize: level.gridSize,
            fruitCount: level.fruitCount,
            startPosition: level.startPosition,
            targetFruit: level.targetFruit,
            grid: Array(repeating: Array(repeating: Fruit.nut, count: level.gridSize), count: level.gridSize),
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0,
            gameHistory: []
        )
        
        initializeGame()
    }

    private func initializeGame() {
        generateRandomGrid()
        updatePlayerArea()
    }

    private func generateRandomGrid() {
        // Tijdelijke implementatie
        for row in 0..<gameState.gridSize {
            for col in 0..<gameState.gridSize {
                let randomIndex = Int.random(in: 0..<min(gameState.fruitCount, GameState.availableFruits.count))
                gameState.grid[row][col] = GameState.availableFruits[randomIndex]
            }
        }
    }

    func resetGame() {
        gameState = GameState(
            gridSize: gameState.gridSize,
            fruitCount: gameState.fruitCount,
            startPosition: gameState.startPosition,
            targetFruit: gameState.targetFruit,
            grid: Array(repeating: Array(repeating: Fruit.nut, count: gameState.gridSize), count: gameState.gridSize),
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0,
            gameHistory: []
        )
        
        initializeGame()
    }

    private func updatePlayerArea() {
        // Initieel alleen de startpositie
        gameState.currentPlayerArea = [gameState.startPosition]
    }

    func makeMove(fruit: Fruit, onCellsGained: ((Int, CGPoint) -> Void)? = nil) {
        // Bewaar huidige state in history voordat we de move maken
        let historyEntry = GameHistoryEntry(
            grid: gameState.grid,
            currentPlayerArea: gameState.currentPlayerArea,
            moveCount: gameState.moveCount,
            totalScore: gameState.totalScore
        )
        gameState.gameHistory.append(historyEntry)
        
        // Bewaar oude area
        let oldPlayerArea = gameState.currentPlayerArea
        
        // Update de kleur van alle huidige player area cellen
        for position in gameState.currentPlayerArea {
            gameState.grid[position.row][position.col] = fruit
        }
        
        // Nu uitbreiden naar aangrenzende cellen van deze kleur
        gameState.currentPlayerArea = getConnectedArea(from: gameState.startPosition, with: fruit)
        
        // Bereken nieuwe cellen
        let newCells = gameState.currentPlayerArea.subtracting(oldPlayerArea)
        let cellsGained = newCells.count
        let pointsEarned = cellsGained * cellsGained * 10
        
        gameState.moveCount += 1
        gameState.totalScore += pointsEarned
        
        if cellsGained > 0 {
            SoundManager.shared.playMoveSound()
            
            // Haptic feedback gebaseerd op grootte van de zet
            if cellsGained >= 10 {
                SoundManager.shared.heavyHaptic() // Grote zet
            } else if cellsGained >= 5 {
                SoundManager.shared.mediumHaptic() // Medium zet
            } else {
                SoundManager.shared.lightHaptic() // Kleine zet
            }
            
            if pointsEarned > 100 {
                SoundManager.shared.playScoreGainSound()
            }
        } else {
            // Geen nieuwe cellen - warning haptic
            SoundManager.shared.warningHaptic()
        }
        
        // Trigger particle effect vanaf center van nieuwe cellen
        if cellsGained > 0, let callback = onCellsGained {
            let centerPosition = GridPositionHelper.shared.getCenterPosition(for: newCells)
            callback(pointsEarned, centerPosition)
        }
        
        // Check win condition
        checkWinCondition()
    }

    private func getConnectedArea(from position: GridPosition, with fruit: Fruit) -> Set<GridPosition> {
        var visited: Set<GridPosition> = []
        var toVisit: [GridPosition] = [position]
        
        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()
            
            if visited.contains(current) { continue }
            if gameState.grid[current.row][current.col] != fruit { continue }
            
            visited.insert(current)
            
            for adjacent in current.adjacentPositions(in: gameState.gridSize) {
                if !visited.contains(adjacent) && gameState.grid[adjacent.row][adjacent.col] == fruit {
                    toVisit.append(adjacent)
                }
            }
        }
        
        return visited
    }

    func undoLastMove() -> Bool {
        guard !gameState.gameHistory.isEmpty else {
            SoundManager.shared.errorHaptic()
            return false
        }
        
        let previousState = gameState.gameHistory.removeLast()
        
        gameState.grid = previousState.grid
        gameState.currentPlayerArea = previousState.currentPlayerArea
        gameState.moveCount = previousState.moveCount
        gameState.totalScore = previousState.totalScore
        gameState.isCompleted = false // Reset completion state

        SoundManager.shared.playUndoSound()
        SoundManager.shared.mediumHaptic()
        
        return true
    }

    var canUndo: Bool {
        return !gameState.gameHistory.isEmpty
    }

    func goToNextLevel() -> Bool {
        if let nextLevel = levelManager.nextLevel() {
            levelManager.selectLevel(nextLevel)
            loadLevel(nextLevel)
            return true
        }
        return false
    }

    var hasNextLevel: Bool {
        return levelManager.nextLevel() != nil
    }
    
    private func checkWinCondition() {
        if gameState.currentPlayerArea.count == gameState.gridSize * gameState.gridSize {
            // Check of target kleur wordt gehaald (als er een target is)
            if let targetFruit = gameState.targetFruit {
                let currentGridFruit = gameState.grid[gameState.startPosition.row][gameState.startPosition.col]
                
                if currentGridFruit == targetFruit {
                    // Win: alle cellen + juiste kleur
                    gameState.isCompleted = true
                    let stars = calculateStars()
                    SoundManager.shared.playLevelCompleteSound()
                    SoundManager.shared.successHaptic()
                    levelManager.completeLevel(levelManager.currentLevel.id, withScore: gameState.totalScore, stars: stars)
                } else {
                    // Wrong color - lose a life
                    let hasLivesLeft = levelManager.loseLife()
                    
                    if hasLivesLeft {
                        // Reset level met feedback
                        resetLevelWithLifeLoss()
                    } else {
                        // Game over
                        triggerGameOver()
                    }
                }
            } else {
                // Geen target kleur constraint - gewoon alle cellen is genoeg
                gameState.isCompleted = true
                let stars = calculateStars()
                SoundManager.shared.playLevelCompleteSound()
                SoundManager.shared.successHaptic()
                levelManager.completeLevel(levelManager.currentLevel.id, withScore: gameState.totalScore, stars: stars)
            }
        }
    }

    private func resetLevelWithLifeLoss() {
        SoundManager.shared.errorHaptic()
        
        // Reset game state maar behoud level
        gameState.grid = Array(repeating: Array(repeating: Fruit.nut, count: gameState.gridSize), count: gameState.gridSize)
        gameState.currentPlayerArea = []
        gameState.moveCount = 0
        gameState.totalScore = 0
        gameState.gameHistory = []
        gameState.isCompleted = false
        
        // Regenereer level
        initializeGame()
    }

    private func triggerGameOver() {
        SoundManager.shared.errorHaptic()
        gameState.isCompleted = true // Dit triggert de overlay, maar dan voor game over
    }

    private func calculateStars() -> Int {
        let targetStars = levelManager.currentLevel.targetStars
        let score = gameState.totalScore
        
        if score >= targetStars[2] {
            return 3 // ⭐⭐⭐
        } else if score >= targetStars[1] {
            return 2 // ⭐⭐
        } else if score >= targetStars[0] {
            return 1 // ⭐
        } else {
            return 1 // Minimaal 1 ster voor completion
        }
    }
}
