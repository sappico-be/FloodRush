import SwiftUI

struct GameLevel {
    let id: Int
    let packId: Int
    let levelInPack: Int // 1-20 bijvoorbeeld
    let gridSize: Int
    let colorCount: Int
    let startPosition: GridPosition
    let targetColor: Color?
    let targetStars: [Int] // Punten nodig voor 1, 2, 3 sterren
    
    var displayName: String {
        return "Level \(levelInPack)"
    }
}
