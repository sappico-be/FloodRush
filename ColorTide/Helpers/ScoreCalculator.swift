import SwiftUI

struct ScoreCalculator {
    static func calculateFinalScore(
        level: GameLevel,
        actualMoves: Int,
        cellsGainedPerMove: [Int] = []
    ) -> (score: Int, stars: Int, efficiency: Double) {
        
        // Basis score berekening
        let penalty = getPenaltyPerMove(for: level.gridSize)
        let rawScore = max(
            level.baseScore / 10, // Minimum 10% van base score
            level.baseScore - (actualMoves * penalty)
        )
        
        // Coverage bonus (bonus voor grote moves)
        let coverageBonus = cellsGainedPerMove.reduce(0) { total, cellsGained in
            total + calculateCoverageBonus(cellsGained: cellsGained, gridSize: level.gridSize)
        }
        
        // Efficiency berekening
        let efficiency = min(1.0, Double(level.targetMoves) / Double(actualMoves))
        
        // Final score
        let finalScore = max(100, rawScore + coverageBonus)
        
        // Stars berekening - NU MET actualMoves parameter
        let stars = calculateStars(score: finalScore, level: level, actualMoves: actualMoves)
        
        return (finalScore, stars, efficiency)
    }
    
    static func calculateMoveScore(cellsGained: Int, gridSize: Int) -> Int {
        // Vierkante punten voor grote moves
        let basePoints = cellsGained * cellsGained * 10
        
        // Extra bonus voor zeer grote moves
        let bonusMultiplier = cellsGained > gridSize ? 1.5 : 1.0
        
        return Int(Double(basePoints) * bonusMultiplier)
    }
    
    static func calculateCoverageBonus(cellsGained: Int, gridSize: Int) -> Int {
        let totalCells = gridSize * gridSize
        let coverage = Double(cellsGained) / Double(totalCells)
        
        // Bonus voor grote coverage in één move
        if coverage >= 0.3 { // 30%+ van grid in één move
            return Int(coverage * 1000)
        }
        return 0
    }
    
    static func calculateStars(score: Int, level: GameLevel, actualMoves: Int) -> Int {
        // 3 sterren alleen mogelijk binnen target moves (perfecte efficiency)
        if actualMoves <= level.targetMoves && score >= level.starThresholds.three {
            return 3
        } else if score >= level.starThresholds.two {
            return 2
        } else if score >= level.starThresholds.one {
            return 1
        } else {
            return 1 // Altijd minimaal 1 ster voor completion
        }
    }
    
    private static func getPenaltyPerMove(for gridSize: Int) -> Int {
        switch gridSize {
        case 6: return 300
        case 8: return 400
        case 10: return 500
        default: return 350
        }
    }
}
