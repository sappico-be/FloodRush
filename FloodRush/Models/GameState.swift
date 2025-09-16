import SwiftUI

struct GameState {
    let gridSize: Int
    let fruitCount: Int
    let startPosition: GridPosition
    let targetFruit: Fruit?
    var grid: [[Fruit]]
    var currentPlayerArea: Set<GridPosition>
    var moveCount: Int
    var isCompleted: Bool
    var totalScore: Int
    var gameHistory: [GameHistoryEntry] = []
    
    // Available colors static property
    static let availableFruits: [Fruit] = [.nut, .cherry, .strawberry, .muchroom, .clover, .berry, .grapes]
}

struct GridPosition: Hashable, Equatable {
    let row: Int
    let col: Int
    
    func adjacentPositions(in gridSize: Int) -> [GridPosition] {
        var adjacent: [GridPosition] = []
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        
        for (dRow, dCol) in directions {
            let newRow = row + dRow
            let newCol = col + dCol
            
            if newRow >= 0 && newRow < gridSize && newCol >= 0 && newCol < gridSize {
                adjacent.append(GridPosition(row: newRow, col: newCol))
            }
        }
        
        return adjacent
    }
}
