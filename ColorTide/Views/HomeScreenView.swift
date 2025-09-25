import SwiftUI
import Combine

struct HomeScreenView: View {
    @ObservedObject var levelManager: APILevelManager
    let onPlayTapped: () -> Void
    let onLevelPacksTapped: () -> Void
    let onLeaderboardTapped: () -> Void
    let onSettingsTapped: () -> Void
    
    @StateObject private var gameCenterManager = GameCenterManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("main_game_background_2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .scaleEffect(1.1)
                    .clipped()

                logoView(geometry: geometry)
                
                // Main buttons
                VStack(spacing: 30.0) {
                    startButton
                    HStack(spacing: 30) {
                        levelsButton
                        leaderboardButton
                        settingsButton
                    }
                    
                    // NIEUW: GameCenter status indicator
                    if gameCenterManager.isAuthenticated {
                        HStack {
                            Image(systemName: "gamecontroller.fill")
                                .foregroundColor(.green)
                            Text("GameCenter Connected")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                    } else {
                        HStack {
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.orange)
                            Text("GameCenter Connecting...")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                        .opacity(0.7)
                    }
                }
                .padding(.top, 70.0)

                Image("green_background_overlay")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
    }

    private func logoView(geometry: GeometryProxy) -> some View {
        ZStack {
            let position = CGPoint(
                x: geometry.size.width / 2,
                y: geometry.size.height * 0.25
            )

            Image("logo_forest_run")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 128)
                .scaleEffect(1.4)
                .position(position)
        }
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
                normalImage: "play_button",
                pressedImage: "play_button",
                height: 110.0
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
                normalImage: "levels-button-3",
                pressedImage: "levels-button-3",
                height: 70.0
            )
        )
    }
    
    private var leaderboardButton: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            SoundManager.shared.lightHaptic()
            // NIEUW: Show GameCenter leaderboards
            levelManager.showLeaderboards()
        }) {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "leaderboard-button",
                pressedImage: "leaderboard-button",
                height: 70.0
            )
        )
        .opacity(gameCenterManager.isAuthenticated ? 1.0 : 0.6) // Visual feedback
        .animation(.easeInOut(duration: 0.3), value: gameCenterManager.isAuthenticated)
    }

    private var settingsButton: some View {
        Button(action: {
            SoundManager.shared.playButtonTapSound()
            onSettingsTapped()
        }) {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "settings-button-2",
                pressedImage: "settings-button-2",
                height: 70.0
            )
        )
    }
}

#Preview {
    HomeScreenView(
        levelManager: APILevelManager()) {
            
        } onLevelPacksTapped: {
            
        } onLeaderboardTapped: {
            
        } onSettingsTapped: {
            
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
