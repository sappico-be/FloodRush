import SwiftUI
import Combine

struct HomeScreenView: View {
    @ObservedObject var levelManager: LevelManager
    let onPlayTapped: () -> Void
    let onLevelPacksTapped: () -> Void
    let onSettingsTapped: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                livesButton
                Spacer()
                pointsView
            }
            .padding(.top, 0)

            VStack(spacing: 40) {
                // Game title
                Image("ignite_grid_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 175)
                    .clipped()
                    .padding(.top, 65.0)
                
                // Main buttons
                VStack(alignment: .center, spacing: 40.0) {
                    // Big Play button
                    startButton
                    levelsButton
                }
                
                Spacer()

                HStack {
                    Spacer()
                    settingsButton
                }
            }
        }
        .padding(.horizontal)
        .background(
            Image("ignite_grid_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    private var livesButton: some View {
        ZStack(alignment: .leading) {
            Image("icon_heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .padding(.leading, 0.0)
            Text("\(levelManager.currentLives)")
                .font(.custom("FredokaOne-Regular", size: 16.0))
                .foregroundStyle(.white)
                .padding(.leading, 20.0)
                .padding(.top, -5.0)
                .frame(width: 35.0)

            Button {
                // ACTION LATER
            } label: {
                EmptyView()
            }
            .buttonStyle(
                ImageButtonStyle(
                    normalImage: "icon_add_button",
                    pressedImage: "icon_add_button",
                    height: 40
                )
            )
            .padding(.leading, 30.0)
            .padding(.top, 35.0)

        }
    }

    private var pointsView: some View {
        ZStack(alignment: .trailing) {
            Image("coins_background")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 45)
                .padding(.trailing, 25.0)
            
            Text("\(levelManager.totalScore)")
                .font(.custom("FredokaOne-Regular", size: 16.0))
                .foregroundStyle(Color(red: 157/255.0, green: 97/255.0, blue: 99/255.0))
                .padding(.trailing, 50.0)
            
            Button {
                // ACTION LATER
            } label: {
                EmptyView()
            }
            .buttonStyle(
                ImageButtonStyle(
                    normalImage: "icon_add_button",
                    pressedImage: "icon_add_button",
                    height: 40
                )
            )
            .padding(.trailing, 0.0)
        }
    }

    private var startButton: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            SoundManager.shared.lightHaptic()
            onPlayTapped()
        }) {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "start_button",
                pressedImage: "start_button",
                height: 80.0
            )
        )
    }

    private var levelsButton: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            SoundManager.shared.lightHaptic()
            onLevelPacksTapped()
        }) {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "levels_button",
                pressedImage: "levels_button",
                height: 60.0
            )
        )
    }

    private var settingsButton: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            onSettingsTapped?() // Nieuwe callback
        }) {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "settings_button",
                pressedImage: "settings_button",
                height: 40.0
            )
        )
    }
}

struct ImageButtonStyle: ButtonStyle {
    let normalImage: String
    let pressedImage: String
    let height: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        Image(configuration.isPressed ? pressedImage : normalImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
