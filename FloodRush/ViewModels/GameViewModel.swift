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

    private func updatePlayerArea() {
        // Initieel alleen de startpositie
        gameState.currentPlayerArea = [gameState.startPosition]
    }

    func makeMove(color: Color) {
        // Bewaar oude area size
        let oldAreaSize = gameState.currentPlayerArea.count

        // Update de kleur van alle huidige player area cellen
        for position in gameState.currentPlayerArea {
            gameState.grid[position.row][position.col] = color
        }
        
        // Nu uitbreiden naar aangrenzende cellen van deze kleur
        gameState.currentPlayerArea = getConnectedArea(from: gameState.startPosition, with: color)

        // Bereken punten exponentieel
        let newAreaSize = gameState.currentPlayerArea.count
        let cellsGained = newAreaSize - oldAreaSize
        let pointsEarned = cellsGained * cellsGained
        
        gameState.moveCount += 1
        gameState.totalScore += pointsEarned * 10

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
    
    private func checkWinCondition() {
        if gameState.currentPlayerArea.count == gameState.gridSize * gameState.gridSize {
            gameState.isCompleted = true
        }
    }
}
