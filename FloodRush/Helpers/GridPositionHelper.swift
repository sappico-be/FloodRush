import SwiftUI
import Combine

class GridPositionHelper: ObservableObject {
    static let shared = GridPositionHelper()
    
    private var gridFrame: CGRect = .zero
    private var cellSize: CGFloat = 0
    private var spacing: CGFloat = 0
    private var gridSize: Int = 0
    
    func updateGridInfo(frame: CGRect, cellSize: CGFloat, spacing: CGFloat, gridSize: Int) {
        self.gridFrame = frame
        self.cellSize = cellSize
        self.spacing = spacing
        self.gridSize = gridSize
    }
    
    func getCenterPosition(for positions: Set<GridPosition>) -> CGPoint {
        guard !positions.isEmpty else { return .zero }
        
        let avgRow = positions.reduce(0) { $0 + $1.row } / positions.count
        let avgCol = positions.reduce(0) { $0 + $1.col } / positions.count
        
        let x = gridFrame.minX + (CGFloat(avgCol) * (cellSize + spacing)) + cellSize/2
        let y = gridFrame.minY + (CGFloat(avgRow) * (cellSize + spacing)) + cellSize/2
        
        return CGPoint(x: x, y: y)
    }
}
