import SwiftUI
import AVFoundation

struct ColorPickerView: View {
    let availableColors: [Color]
    let targetColor: Color?
    let isDisabled: Bool
    let onColorSelected: (Color) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(availableColors, id: \.self) { color in
                Button(action: {
                    if !isDisabled {
                        SoundManager.shared.playButtonTapSound()
                        SoundManager.shared.selectionHaptic()
                        onColorSelected(color)
                    }
                }) {
                    Circle()
                        .fill(color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .overlay {
                            // Target indicator
                            if color == targetColor {
                                Image(systemName: "target")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2)
                            }
                        }
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .padding()
    }
}
