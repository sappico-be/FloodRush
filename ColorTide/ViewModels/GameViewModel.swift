import SwiftUI
import Combine
import AVFoundation

class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState
    let levelManager: APILevelManager
    private var usedUndo: Bool = false // NIEUW: Track undo usage

    init(levelManager: APILevelManager) {
        self.levelManager = levelManager
        let level = levelManager.currentLevel
        
        self.gameState = GameState(
            gridSize: level.gridSize,
            fruitCount: level.fruitCount,
            startPosition: level.startPosition,
            targetFruit: level.targetFruit,
            grid: level.getGrid(), // NIEUW: Gebruik predefined grid
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0,
            gameHistory: []
        )
        
        initializeGame()
    }

    func loadLevel(_ level: GameLevel) {
        usedUndo = false // Reset undo tracking
        gameState = GameState(
            gridSize: level.gridSize,
            fruitCount: level.fruitCount,
            startPosition: level.startPosition,
            targetFruit: level.targetFruit,
            grid: level.getGrid(), // NIEUW: Gebruik predefined grid
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0,
            gameHistory: []
        )
        
        initializeGame()
    }

    private func initializeGame() {
        updatePlayerArea()
    }

    func resetGame() {
        usedUndo = false // Reset undo tracking
        let currentLevel = levelManager.currentLevel
        
        gameState = GameState(
            gridSize: gameState.gridSize,
            fruitCount: gameState.fruitCount,
            startPosition: gameState.startPosition,
            targetFruit: gameState.targetFruit,
            grid: currentLevel.getGrid(), // NIEUW: Herlaad exact hetzelfde predefined grid
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
        // Bewaar huidige state in history
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
        
        // Uitbreiden naar aangrenzende cellen
        gameState.currentPlayerArea = getConnectedArea(from: gameState.startPosition, with: fruit)
        
        // Bereken nieuwe cellen en punten
        let newCells = gameState.currentPlayerArea.subtracting(oldPlayerArea)
        let cellsGained = newCells.count
        
        // Score berekening
        let movePoints = ScoreCalculator.calculateMoveScore(
            cellsGained: cellsGained,
            gridSize: gameState.gridSize
        )
        
        gameState.moveCount += 1
        gameState.totalScore += movePoints
        
        // Bewaar cells gained voor final score berekening
        if gameState.cellsGainedPerMove == nil {
            gameState.cellsGainedPerMove = []
        }
        gameState.cellsGainedPerMove?.append(cellsGained)
        
        // Sound en haptic feedback
        if cellsGained > 0 {
            SoundManager.shared.playMoveSound()
            
            if cellsGained >= gameState.gridSize * 2 {
                SoundManager.shared.heavyHaptic()
            } else if cellsGained >= gameState.gridSize {
                SoundManager.shared.mediumHaptic()
            } else {
                SoundManager.shared.lightHaptic()
            }
            
            if movePoints > 200 {
                SoundManager.shared.playScoreGainSound()
            }
        } else {
            SoundManager.shared.warningHaptic()
        }
        
        // Particle effect
        if cellsGained > 0, let callback = onCellsGained {
            let centerPosition = GridPositionHelper.shared.getCenterPosition(for: newCells)
            callback(movePoints, centerPosition)
        }
        
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
        
        usedUndo = true // NIEUW: Mark that undo was used
        
        let previousState = gameState.gameHistory.removeLast()
        
        gameState.grid = previousState.grid
        gameState.currentPlayerArea = previousState.currentPlayerArea
        gameState.moveCount = previousState.moveCount
        gameState.totalScore = previousState.totalScore
        gameState.isCompleted = false

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
            gameState.isCompleted = true
            
            // Final score berekening
            let result = ScoreCalculator.calculateFinalScore(
                level: levelManager.currentLevel,
                actualMoves: gameState.moveCount,
                cellsGainedPerMove: gameState.cellsGainedPerMove ?? []
            )
            
            // Update final score
            gameState.totalScore = result.score
            
            SoundManager.shared.playLevelCompleteSound()
            SoundManager.shared.successHaptic()
            
            // Complete level met GameCenter data
            levelManager.completeLevel(
                levelManager.currentLevel.id,
                withScore: result.score,
                stars: result.stars,
                moves: gameState.moveCount, // NIEUW: Pass moves
                usedUndo: usedUndo // NIEUW: Pass undo usage
            )
        }
    }

    private func resetLevelWithLifeLoss() {
        SoundManager.shared.errorHaptic()
        
        let currentLevel = levelManager.currentLevel
        
        // Reset game state - gebruik weer exact hetzelfde predefined grid!
        gameState.grid = currentLevel.getGrid()
        gameState.currentPlayerArea = []
        gameState.moveCount = 0
        gameState.totalScore = 0
        gameState.gameHistory = []
        gameState.isCompleted = false
        
        // Reinitialize
        initializeGame()
    }

    private func triggerGameOver() {
        SoundManager.shared.errorHaptic()
        gameState.isCompleted = true
    }
}
