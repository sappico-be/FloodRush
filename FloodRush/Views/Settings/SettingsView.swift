import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject private var soundManager = SoundManager.shared
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
                // Audio section
                SettingsSectionView(title: "Audio") {
                    SettingsToggleRow(
                        title: "Sound Effects",
                        subtitle: "Play sounds for moves and actions",
                        icon: "speaker.2.fill",
                        isOn: $soundManager.isSoundEnabled
                    )
                    
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
                    .opacity(1.0)
                    
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
