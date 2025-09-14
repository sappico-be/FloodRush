import SwiftUI
import AVFoundation
import Combine
import UIKit

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var isSoundEnabled: Bool = true
    @Published var isHapticEnabled: Bool = true

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // Voor nu gebruiken we system sounds, later custom audio
    func playMoveSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Pop sound
    }
    
    func playSuccessSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1005) // Success sound
    }
    
    func playLevelCompleteSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1016) // Achievement sound
    }
    
    func playButtonTapSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // Button tap
    }
    
    func playScoreGainSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1103) // Score gain
    }
    
    func playUndoSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1102) // Undo sound
    }
    
    // Later: custom audio files
    private func playCustomSound(_ soundName: String) {
        guard isSoundEnabled else { return }
        
        if let player = audioPlayers[soundName] {
            player.stop()
            player.currentTime = 0
            player.play()
        } else {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
                print("Could not find sound file: \(soundName)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                audioPlayers[soundName] = player
                player.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }

    // MARK: - Haptic Methods
    func lightHaptic() {
        guard isHapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func mediumHaptic() {
        guard isHapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func heavyHaptic() {
        guard isHapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func successHaptic() {
        guard isHapticEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func warningHaptic() {
        guard isHapticEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func errorHaptic() {
        guard isHapticEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    func selectionHaptic() {
        guard isHapticEnabled else { return }
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
}
