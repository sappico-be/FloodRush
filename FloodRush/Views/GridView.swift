import SwiftUI

struct GridView: View {
    let gameState: GameState
    let screenPadding: CGFloat = 30
    let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = max(geometry.size.width, 0)
            let totalSpacing = spacing * CGFloat(gameState.gridSize - 1)
            let cellSize = max((availableWidth - totalSpacing) / CGFloat(gameState.gridSize), 1)
            
            VStack(spacing: spacing) {
                ForEach(0..<gameState.gridSize, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<gameState.gridSize, id: \.self) { col in
                            CellView(
                                color: gameState.grid[row][col],
                                isInPlayerArea: gameState.currentPlayerArea.contains(
                                    GridPosition(row: row, col: col)
                                )
                            )
                            .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .frame(width: availableWidth, height: availableWidth)
            .cornerRadius(8)
        }
        .aspectRatio(1, contentMode: .fit) // Houdt grid vierkant
    }
}

struct CellView: View {
    let color: Color
    let isInPlayerArea: Bool
    
    var body: some View {
        Rectangle()
            .fill(color)
            .overlay(
                // Border om player area te tonen
                Rectangle()
                    .stroke(isInPlayerArea ? Color.yellow : Color.clear, lineWidth: 2)
            )
    }
}
