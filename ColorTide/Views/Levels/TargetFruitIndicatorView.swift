import SwiftUI

// Add this new view to show target fruit
struct TargetFruitIndicator: View {
    let targetFruit: Fruit?
    
    var body: some View {
        if let targetFruit = targetFruit {
            VStack(spacing: 4) {
                Text("Target:")
                    .font(.custom("helsinki", size: 10))
                    .foregroundColor(.white)
                
                ZStack {
                    Image("wooden-power-up-form")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    
                    Image(targetFruit.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                .shadow(color: .yellow, radius: 2)
            }
        }
    }
}
