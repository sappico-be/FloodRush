import SwiftUI

struct LevelButtonView: View {
    let level: GameLevel
    let levelManager: APILevelManager
    let onTap: () -> Void
    
    private var isUnlocked: Bool {
        levelManager.isLevelUnlocked(level.id)
    }
    
    private var isCompleted: Bool {
        levelManager.isLevelCompleted(level.id)
    }
    
    private var stars: Int {
        levelManager.getStarsForLevel(level.id)
    }
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            SoundManager.shared.selectionHaptic()
            onTap()
        }) {
            VStack(spacing: 4) {
                // Level nummer of lock icon
                if isUnlocked {
                    Text("\(level.id)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                // Sterren
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundColor(index < stars ? .yellow : .gray.opacity(0.3))
                    }
                }
            }
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(
                        isCompleted ?
                            LinearGradient(colors: [.green, .blue], startPoint: .top, endPoint: .bottom) :
                        isUnlocked ?
                            LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom) :
                            LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )
            )
            .shadow(color: isUnlocked ? .blue.opacity(0.3) : .clear, radius: 4)
        }
        .disabled(!isUnlocked)
    }
}
