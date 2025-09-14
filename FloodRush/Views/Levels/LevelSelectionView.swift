import SwiftUI

struct LevelSelectionView: View {
    @ObservedObject var levelManager: LevelManager
    let onLevelSelected: (GameLevel) -> Void
    let onBack: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Button("← Back") {
                            onBack()
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Select Level")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Placeholder voor symmetrie
                        Text("← Back")
                            .opacity(0)
                    }
                    .padding(.horizontal)
                    
                    // Level packs
                    ForEach(levelManager.availablePacks, id: \.id) { pack in
                        LevelPackView(pack: pack, levelManager: levelManager) { level in
                            levelManager.selectLevel(level)
                            onLevelSelected(level)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
