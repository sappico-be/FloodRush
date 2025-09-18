import SwiftUI

struct GameLevel {
    let id: Int
    let gridSize: Int
    let fruitCount: Int
    let startPosition: GridPosition
    let targetFruit: Fruit?
    let targetMoves: Int
    let baseScore: Int
    let predefinedGrid: [[Fruit]]
    
    var displayName: String {
        return "Level \(id)"
    }
    
    // NIEUW: Bereken ster thresholds
    var starThresholds: (one: Int, two: Int, three: Int) {
        let efficiency85 = max(100, baseScore - (targetMoves + 8) * movesPenalty)
        let efficiency65 = max(100, baseScore - (targetMoves + 3) * movesPenalty)
        let efficiency40 = max(100, baseScore - targetMoves * movesPenalty)
        
        return (efficiency40, efficiency65, efficiency85)
    }
    
    private var movesPenalty: Int {
        switch gridSize {
        case 6: return 300
        case 8: return 400
        case 10: return 500
        default: return 350
        }
    }
    
    // NIEUW: Gewoon het predefined grid teruggeven
    func getGrid() -> [[Fruit]] {
        return predefinedGrid
    }
}
