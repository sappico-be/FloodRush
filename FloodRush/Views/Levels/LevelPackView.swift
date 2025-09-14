import SwiftUI

struct LevelPackView: View {
    let pack: LevelPack
    let levelManager: LevelManager
    let onLevelSelected: (GameLevel) -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Pack header
            HStack {
                Text(pack.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Progress indicator
                let completedCount = pack.levels.filter { levelManager.isLevelCompleted($0.id) }.count
                Text("\(completedCount)/\(pack.levels.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Level grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(pack.levels, id: \.id) { level in
                    LevelButtonView(
                        level: level,
                        levelManager: levelManager,
                        onTap: {
                            if levelManager.isLevelUnlocked(level.id) {
                                onLevelSelected(level)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}
