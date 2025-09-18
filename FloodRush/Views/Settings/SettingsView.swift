import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject private var soundManager = SoundManager.shared
    @StateObject private var gameCenterManager = GameCenterManager.shared
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button("← Back") {
                    SoundManager.shared.playButtonTapSound()
                    onBack()
                }
                .font(.headline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Placeholder for symmetry
                Text("← Back")
                    .opacity(0)
            }
            .padding(.horizontal)
            
            // Settings content
            VStack(spacing: 20) {
                // GameCenter section - NIEUW!
                if gameCenterManager.isAuthenticated {
                    SettingsSectionView(title: "GameCenter") {
                        Button(action: {
                            SoundManager.shared.playButtonTapSound()
                            gameCenterManager.showAchievements()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "trophy.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View Achievements")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("See your unlocked achievements")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        Button(action: {
                            SoundManager.shared.playButtonTapSound()
                            gameCenterManager.showLeaderboards()
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "list.number")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("View Leaderboards")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Compare your scores with others")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    // GameCenter niet ingelogd
                    SettingsSectionView(title: "GameCenter") {
                        HStack(spacing: 15) {
                            Image(systemName: "gamecontroller")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Not Connected")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Sign in to access achievements and leaderboards")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .opacity(0.6)
                    }
                }
                
                // Audio section
                SettingsSectionView(title: "Audio") {
                    SettingsToggleRow(
                        title: "Sound Effects",
                        subtitle: "Play sounds for moves and actions",
                        icon: "speaker.2.fill",
                        isOn: $soundManager.isSoundEnabled
                    )
                    
                    Divider()
                    
                    // Future: Music toggle
                    SettingsToggleRow(
                        title: "Background Music",
                        subtitle: "Play ambient background music",
                        icon: "music.note",
                        isOn: .constant(false)
                    )
                    .opacity(0.5) // Disabled for now
                }
                
                // Gameplay section
                SettingsSectionView(title: "Gameplay") {
                    SettingsToggleRow(
                        title: "Haptic Feedback",
                        subtitle: "Feel vibrations on moves",
                        icon: "iphone.radiowaves.left.and.right",
                        isOn: $soundManager.isHapticEnabled
                    )
                    
                    Divider()
                    
                    SettingsToggleRow(
                        title: "Auto-save Progress",
                        subtitle: "Automatically save your game progress",
                        icon: "externaldrive.fill",
                        isOn: .constant(true)
                    )
                    .opacity(0.5) // Future feature
                }
                
                // About section
                SettingsSectionView(title: "About") {
                    SettingsInfoRow(
                        title: "Version",
                        value: "1.0.0",
                        icon: "info.circle"
                    )
                    
                    Divider()
                    
                    SettingsInfoRow(
                        title: "Developer",
                        value: "Sappico V.O.F.",
                        icon: "person.circle"
                    )
                }
            }
            
            Spacer()
        }
        .padding(.top)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SettingsView(onBack: {})
}
