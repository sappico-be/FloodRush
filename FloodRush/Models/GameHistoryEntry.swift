import SwiftUI

struct GameHistoryEntry {
    let grid: [[Fruit]]
    let currentPlayerArea: Set<GridPosition>
    let moveCount: Int
    let totalScore: Int
}
