import SwiftUI
import AVFoundation

struct ColorPickerView: View {
    let availableFruits: [Fruit]
    let targetFruit: Fruit?
    let isDisabled: Bool
    let onFruitSelected: (Fruit) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(availableFruits, id: \.self) { fruit in
                Button(action: {
                    if !isDisabled {
                        SoundManager.shared.playButtonTapSound()
                        SoundManager.shared.selectionHaptic()
                        onFruitSelected(fruit)
                    }
                }) {
                    Image("wooden-power-up-form")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxHeight: .infinity
                        )
                        .clipped()
                        .overlay {
                            Image(fruit.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(10.0)
                        }
                }
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
    }
}
