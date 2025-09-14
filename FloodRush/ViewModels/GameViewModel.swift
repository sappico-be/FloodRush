import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published private(set) var gameState: GameState

    init(gridSize: Int, colorCount: Int, startPosition: GridPosition) {
        self.gameState = GameState(
            gridSize: gridSize,
            colorCount: colorCount,
            startPosition: startPosition,
            grid: Array(repeating: Array(repeating: Color.gray, count: gridSize), count: gridSize),
            currentPlayerArea: [],
            moveCount: 0,
            isCompleted: false,
            totalScore: 0
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
                let randomIndex = Int.random(in: 0..<min(gameState.colorCount, GameState.availableColors.count))
                gameState.grid[row][col] = GameState.availableColors[randomIndex]
            }
        }
    }

    func resetGame() {
        gameState = GameState(
            gridSize: gameState.gridSize,
            colorCount: gameState.colorCount,
            startPosition: gameState.startPosition,
            grid: Array(repeating: Array(repeating: Color.gray, count: gameState.gridSize), count: gameState.gridSize),
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

    func makeMove(color: Color, onCellsGained: ((Int, CGPoint) -> Void)? = nil) {
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
            gameState.grid[position.row][position.col] = color
        }
        
        // Nu uitbreiden naar aangrenzende cellen van deze kleur
        gameState.currentPlayerArea = getConnectedArea(from: gameState.startPosition, with: color)
        
        // Bereken nieuwe cellen
        let newCells = gameState.currentPlayerArea.subtracting(oldPlayerArea)
        let cellsGained = newCells.count
        let pointsEarned = cellsGained * cellsGained * 10
        
        gameState.moveCount += 1
        gameState.totalScore += pointsEarned
        
        // Debug print
        print("Cells gained: \(cellsGained), Points: \(pointsEarned)")
        
        // Trigger particle effect vanaf center van nieuwe cellen
        if cellsGained > 0, let callback = onCellsGained {
            let centerPosition = GridPositionHelper.shared.getCenterPosition(for: newCells)
            print("Triggering particle at: \(centerPosition)")
            callback(pointsEarned, centerPosition)
        }

        if cellsGained > 0 {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        // Check win condition
        checkWinCondition()
    }

    private func getConnectedArea(from position: GridPosition, with color: Color) -> Set<GridPosition> {
        var visited: Set<GridPosition> = []
        var toVisit: [GridPosition] = [position]
        
        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()
            
            if visited.contains(current) { continue }
            if gameState.grid[current.row][current.col] != color { continue }
            
            visited.insert(current)
            
            for adjacent in current.adjacentPositions(in: gameState.gridSize) {
                if !visited.contains(adjacent) && gameState.grid[adjacent.row][adjacent.col] == color {
                    toVisit.append(adjacent)
                }
            }
        }
        
        return visited
    }

    func undoLastMove() -> Bool {
        guard !gameState.gameHistory.isEmpty else { return false }
        
        let previousState = gameState.gameHistory.removeLast()
        
        gameState.grid = previousState.grid
        gameState.currentPlayerArea = previousState.currentPlayerArea
        gameState.moveCount = previousState.moveCount
        gameState.totalScore = previousState.totalScore
        gameState.isCompleted = false // Reset completion state
        
        return true
    }

    var canUndo: Bool {
        return !gameState.gameHistory.isEmpty
    }
    
    private func checkWinCondition() {
        if gameState.currentPlayerArea.count == gameState.gridSize * gameState.gridSize {
            gameState.isCompleted = true
        }
    }
}
