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
                                fruit: gameState.grid[row][col],
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
            .background(
                // Invisible background to capture the grid's position
                Color.clear
                    .onAppear {
                        // Store grid info for position calculation
                        GridPositionHelper.shared.updateGridInfo(
                            frame: CGRect(x: geometry.frame(in: .global).minX,
                                        y: geometry.frame(in: .global).minY,
                                        width: availableWidth,
                                        height: availableWidth),
                            cellSize: cellSize,
                            spacing: spacing,
                            gridSize: gameState.gridSize
                        )
                    }

            )
        }
        .aspectRatio(1, contentMode: .fit) // Houdt grid vierkant
    }
}
