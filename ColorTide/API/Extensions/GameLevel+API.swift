import SwiftUI

// Extension to convert API data to your existing GameLevel struct
extension GameLevel {
    init(from apiLevel: APIGameLevel) {
        self.id = apiLevel.levelNumber
        self.gridSize = apiLevel.safeGridSize       // Use safe accessor
        self.fruitCount = apiLevel.safeFruitCount   // Use safe accessor
        self.startPosition = GridPosition(
            row: apiLevel.safeStartPosition.row,    // Use safe accessor
            col: apiLevel.safeStartPosition.col     // Use safe accessor
        )
        
        // NEW: Convert target fruit string to Fruit enum
        if let targetFruitString = apiLevel.safeTargetFruit {
            self.targetFruit = Fruit.from(string: targetFruitString)
        } else {
            self.targetFruit = nil
        }
        
        self.targetMoves = apiLevel.safeTargetMoves // Use safe accessor
        self.baseScore = apiLevel.safeBaseScore     // Use safe accessor
        
        // Convert string array to Fruit array - handle empty grid
        if !apiLevel.safePredefinedGrid.isEmpty {  // Use safe accessor
            self.predefinedGrid = apiLevel.safePredefinedGrid.map { row in
                row.map { fruitString in
                    Fruit.from(string: fruitString)
                }
            }
        } else {
            // Fallback: create a simple grid
            self.predefinedGrid = Array(repeating:
                Array(repeating: Fruit.nut, count: self.gridSize),
                count: self.gridSize
            )
        }
    }
}
