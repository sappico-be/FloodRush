import SwiftUI

struct LevelStatsView: View {
    let level: GameLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Target: \(level.targetMoves) moves")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(level.gridSize)×\(level.gridSize)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            let thresholds = level.starThresholds
            HStack(spacing: 2) {
                ForEach(0..<3) { index in
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(index == 0 ? thresholds.one : index == 1 ? thresholds.two : thresholds.three)")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
