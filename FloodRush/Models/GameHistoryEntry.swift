import SwiftUI

struct GameHistoryEntry {
    let grid: [[Color]]
    let currentPlayerArea: Set<GridPosition>
    let moveCount: Int
    let totalScore: Int
}
