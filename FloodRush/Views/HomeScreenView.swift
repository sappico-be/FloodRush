import SwiftUI
import Combine

struct HomeScreenView: View {
    @ObservedObject var levelManager: LevelManager
    let onPlayTapped: () -> Void
    let onLevelPacksTapped: () -> Void
    let onSettingsTapped: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        SoundManager.shared.playButtonTapSound()
                        onSettingsTapped?() // Nieuwe callback
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                }
                .padding(.horizontal)
    
                Spacer()
                
                // Game title
                VStack(spacing: 10) {
                    Text("🌊 FloodRush")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Conquer the Grid")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                // Player stats
                VStack(spacing: 15) {
                    StatCardView(
                        title: "Total Score",
                        value: "\(levelManager.totalScore)",
                        icon: "🏆"
                    )
                    
                    HStack(spacing: 20) {
                        StatCardView(
                            title: "Levels",
                            value: "\(levelManager.levelsCompleted)",
                            icon: "🎯"
                        )
                        
                        StatCardView(
                            title: "Stars",
                            value: "\(levelManager.totalStarsEarned)",
                            icon: "⭐"
                        )
                    }
                }
                
                Spacer()
                
                // Main buttons
                VStack(spacing: 20) {
                    // Big Play button
                    Button(action: {
                        SoundManager.shared.playButtonTapSound()
                        SoundManager.shared.lightHaptic()
                        onPlayTapped()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "play.fill")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("PLAY")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let nextLevel = levelManager.getNextUnlockedLevel(),
                                   let pack = levelManager.getCurrentProgressPack() {
                                    Text("\(pack.emoji) Level \(nextLevel.levelInPack)")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.4), radius: 10)
                    }
                    
                    // Level Packs button
                    Button(action: {
                        SoundManager.shared.playButtonTapSound()
                        onLevelPacksTapped()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "square.grid.3x3")
                                .font(.title2)
                            
                            Text("LEVEL PACKS")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.4), radius: 8)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
        }
    }
}
