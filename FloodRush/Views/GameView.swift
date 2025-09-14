import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel(
        gridSize: 4,
        colorCount: 2,
        startPosition: GridPosition(
            row: 0,
            col: 0
        )
    )

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Moves: \(viewModel.gameState.moveCount)")
                        Text("Score: \(viewModel.gameState.totalScore)")
                    }
                    Spacer()
                    Text("Progress: \(viewModel.gameState.currentPlayerArea.count)/\(viewModel.gameState.gridSize * viewModel.gameState.gridSize)")
                }
                .padding(.horizontal)
                
                // Grid
                GridView(gameState: viewModel.gameState)
                    .padding(.horizontal, 30.0)
                
                // Color Picker
                ColorPickerView(
                    availableColors: Array(GameState.availableColors.prefix(viewModel.gameState.colorCount)),
                    isDisabled: viewModel.gameState.isCompleted,
                    onColorSelected: viewModel.makeMove
                )
                .padding(.top, 10.0)
                
                Spacer()
            }
            
            // Win overlay
            if viewModel.gameState.isCompleted {
                WinOverlayView(
                    moveCount: viewModel.gameState.moveCount,
                    score: viewModel.gameState.totalScore
                )
            }
        }
    }
}
