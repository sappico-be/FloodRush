import SwiftUI

struct CellView: View {
    let fruit: Fruit
    let isInPlayerArea: Bool
    let animationDelay: Double
    @State private var animatedFruit: Fruit
    @State private var isAnimating: Bool = false
    @State private var isPulsing: Bool = false
    
    init(fruit: Fruit, isInPlayerArea: Bool, animationDelay: Double = 0) {
        self.fruit = fruit
        self.isInPlayerArea = isInPlayerArea
        self.animationDelay = animationDelay
        self._animatedFruit = State(initialValue: fruit)
    }
    
    var body: some View {
        ZStack {
            Image("block-for-game-item")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Image(fruit.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(5.0)
                .scaleEffect(
                    isAnimating ? 1.1 : (isPulsing && isInPlayerArea ? 1.05 : 1.0) // Combineer beide animaties
                )
                .overlay {
                    if isInPlayerArea {
                        Image("active-game-block")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .onChange(of: fruit) { _, newFruit in
                    if animationDelay > 0 {
                        // Animate color change with delay (ripple effect)
                        DispatchQueue.main.asyncAfter(deadline: .now() + animationDelay) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                animatedFruit = newFruit
                                isAnimating = true
                            }
                            
                            withAnimation(.easeOut(duration: 0.3).delay(0.4)) {
                                isAnimating = false
                            }
                        }
                    } else {
                        animatedFruit = newFruit
                    }
                }
        }
    }
}

enum Fruit: Equatable {
    case nut, cherry, muchroom, berry, clover, strawberry, grapes

    var imageName: String {
        switch self {
        case .nut: return "nut-icon"
        case .cherry: return "cherry-icon"
        case .muchroom: return "muchroom-icon"
        case .berry: return "berry-icon"
        case .clover: return "clover-icon"
        case .strawberry: return "strawberry-icon"
        case .grapes: return "grapes-icon"
        }
    }
}
