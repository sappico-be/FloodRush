import SwiftUI

struct WinOverlayView: View {
    let moveCount: Int
    let score: Int
    let onResetGame: (() -> Void)?
    let onNextLevel: (() -> Void)? // AANGEPAST: Dit triggert nu de animatie
    let onBackToHomeTapped: (() -> Void)?
    let onBackToLevelsTapped: (() -> Void)?
    let hasNextLevel: Bool
    let targetMoves: Int
    let starsEarned: Int

    // Animation states... (rest blijft hetzelfde)
    @State private var star1Offset: CGPoint = CGPoint(x: 0, y: -500)
    @State private var star2Offset: CGPoint = CGPoint(x: 0, y: -600)
    @State private var star3Offset: CGPoint = CGPoint(x: 0, y: -550)
    @State private var star1Scale: CGFloat = 1.0
    @State private var star2Scale: CGFloat = 1.0
    @State private var star3Scale: CGFloat = 1.0
    @State private var star1Shake: CGFloat = 0
    @State private var star2Shake: CGFloat = 0
    @State private var star3Shake: CGFloat = 0
    @State private var star1Rotation: Double = 0
    @State private var star2Rotation: Double = 0
    @State private var star3Rotation: Double = 0
    @State private var screenShake: CGFloat = 0
    @State private var flashEffect: Double = 0
    @State private var heartTextScale: CGFloat = 3.0
    @State private var heartTextOpacity: Double = 0.0
    @State private var efficiencyTextScale: CGFloat = 3.0
    @State private var efficiencyTextOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Flash effect BEHIND everything else
            Rectangle()
                .fill(Color.white.opacity(flashEffect))
                .ignoresSafeArea(.all, edges: .all)
            
            backgroundPanel
                .overlay {
                    starsSection
                }
                .overlay {
                    efficiencyTextOverlay
                }
        }
        .offset(x: screenShake * 0.8, y: screenShake * 0.5 + 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.4).ignoresSafeArea(.all, edges: .all))
        .onAppear {
            startStarAnimation()
            startEfficiencyTextAnimation()
        }
    }
    
    private var backgroundPanel: some View {
        ZStack(alignment: .topTrailing) {
            Image("win-panel-background")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 20.0)
                .overlay(nextButtonOverlay)
                .overlay(contentOverlay)
            
            exitButton
                .padding(.horizontal, 10.0)
                .padding(.top, -5.0)
        }
        .padding(.top, 0.0)
    }
    
    private var nextButtonOverlay: some View {
        VStack {
            if hasNextLevel {
                Spacer()
                nextButton.padding(.bottom, -10.0)
            }
        }
    }
    
    private var contentOverlay: some View {
        VStack(spacing: 10.0) {
            Text("Your score: \(score)")
                .font(.custom("helsinki", size: 22))
            HStack(spacing: 5) {
                Text("Moves: \(moveCount)")
                    .font(.custom("helsinki", size: 22))
                Text("target: \(targetMoves)")
                    .font(.custom("helsinki", size: 12))
            }
            
            HStack(spacing: 20.0) {
                heartsEarnedView
                resetButton
                levelsButton
            }
            .padding(.top, 15.0)
        }
        .foregroundStyle(Color.white)
        .padding(.top, 20.0)
    }
    
    private var efficiencyTextOverlay: some View {
        VStack {
            Spacer()
            
            if moveCount <= targetMoves {
                Image("perfect-text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 55)
                    .scaleEffect(efficiencyTextScale)
                    .opacity(efficiencyTextOpacity)
                    .rotationEffect(.degrees(-15))
                    .shadow(color: .green, radius: efficiencyTextScale > 1.0 ? 10 : 0)
            } else if moveCount <= targetMoves + 3 {
                Image("great-job-text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 55)
                    .scaleEffect(efficiencyTextScale)
                    .opacity(efficiencyTextOpacity)
                    .rotationEffect(.degrees(-15))
                    .shadow(color: .yellow, radius: efficiencyTextScale > 1.0 ? 10 : 0)
            }
            
            Spacer()
        }
    }
    
    private var starsSection: some View {
        VStack {
            HStack(spacing: 0) {
                // Star 1 - Left
                ZStack {
                    Image("star-empty-left-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 55)
                        .opacity(0.3)
                    
                    if starsEarned >= 1 {
                        StarView(
                            imageName: "star-full-left-icon",
                            size: 55,
                            scale: star1Scale,
                            offset: star1Offset,
                            shake: star1Shake,
                            rotation: star1Rotation,
                            isEarned: true
                        )
                    }
                }
                
                // Star 2 - Big center star
                ZStack {
                    Image("star-empty-big-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 77, height: 77)
                        .opacity(0.3)
                    
                    if starsEarned >= 2 {
                        StarView(
                            imageName: "star-full-big-icon",
                            size: 77,
                            scale: star2Scale,
                            offset: star2Offset,
                            shake: star2Shake,
                            rotation: star2Rotation,
                            isEarned: true
                        )
                    }
                }
                .padding(.bottom, 40.0)
                
                // Star 3 - Right
                ZStack {
                    Image("star-empty-right-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 55, height: 55)
                        .opacity(0.3)
                    
                    if starsEarned >= 3 {
                        StarView(
                            imageName: "star-full-right-icon",
                            size: 55,
                            scale: star3Scale,
                            offset: star3Offset,
                            shake: star3Shake,
                            rotation: star3Rotation,
                            isEarned: true
                        )
                    }
                }
            }
            .padding(.horizontal, 15.0)
            .background(
                Image("glow-background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            )
            
            Spacer()
        }
        .padding(.top, -90)
    }
    
    // BELANGRIJK: Next button triggert nu de animatie in plaats van direct naar next level
    private var nextButton: some View {
        Button {
            SoundManager.shared.playButtonTapSound()
            // Dit triggert nu de map view met animatie!
            onNextLevel?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "next-button",
                pressedImage: "next-button",
                height: 65.0
            )
        )
    }
    
    // Alle andere functies blijven hetzelfde...
    private func startStarAnimation() {
        animateStar1()
        animateStar2()
        animateStar3()
    }
    
    private func startEfficiencyTextAnimation() {
        guard moveCount <= targetMoves + 3 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                efficiencyTextScale = 1.0
                efficiencyTextOpacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    efficiencyTextScale = 3.0
                    efficiencyTextOpacity = 0.0
                }
            }
        }
    }
    
    private func animateStar1() {
        guard starsEarned >= 1 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.4)) {
                star1Offset = CGPoint(x: 0, y: 0)
                star1Rotation = 720
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                    star1Scale = 1.4
                }
                
                massiveScreenShake(intensity: 12)
                
                withAnimation(.easeOut(duration: 0.1)) {
                    flashEffect = 0.3
                }
                
                individualStarShake(starIndex: 1, intensity: 10)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        star1Scale = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        flashEffect = 0
                    }
                }
            }
        }
    }
    
    private func animateStar2() {
        guard starsEarned >= 2 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.5)) {
                star2Offset = CGPoint(x: 0, y: 0)
                star2Rotation = 1080
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    notificationFeedback.notificationOccurred(.success)
                }
                
                withAnimation(.spring(response: 0.15, dampingFraction: 0.2)) {
                    star2Scale = 1.8
                }
                
                massiveScreenShake(intensity: 25)
                
                withAnimation(.easeOut(duration: 0.15)) {
                    flashEffect = 0.6
                }
                
                individualStarShake(starIndex: 2, intensity: 20)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        star2Scale = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.8)) {
                        flashEffect = 0
                    }
                }
            }
        }
    }
    
    private func animateStar3() {
        guard starsEarned >= 3 else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeIn(duration: 0.45)) {
                star3Offset = CGPoint(x: 0, y: 0)
                star3Rotation = 540
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
                
                withAnimation(.easeOut(duration: 0.1)) {
                    star3Rotation = 0
                }
                
                withAnimation(.spring(response: 0.25, dampingFraction: 0.3)) {
                    star3Scale = 1.5
                }
                
                massiveScreenShake(intensity: 15)
                
                withAnimation(.easeOut(duration: 0.12)) {
                    flashEffect = 0.4
                }
                
                individualStarShake(starIndex: 3, intensity: 12)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        star3Scale = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        flashEffect = 0
                    }
                }
            }
        }
    }
    
    private func massiveScreenShake(intensity: CGFloat) {
        let duration = 1.0
        let shakeCount = 15
        
        for i in 0..<shakeCount {
            let delay = Double(i) * (duration / Double(shakeCount))
            let decayFactor = 1.0 - (Double(i) / Double(shakeCount))
            let shake = CGFloat.random(in: -intensity...intensity) * CGFloat(decayFactor)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration / Double(shakeCount))) {
                    screenShake = shake
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeOut(duration: 0.4)) {
                screenShake = 0
            }
        }
    }
    
    private func individualStarShake(starIndex: Int, intensity: CGFloat) {
        let duration = 0.6
        let shakeCount = 10
        
        for i in 0..<shakeCount {
            let delay = Double(i) * (duration / Double(shakeCount))
            let decayFactor = 1.0 - (Double(i) / Double(shakeCount))
            let shake = CGFloat.random(in: -intensity...intensity) * CGFloat(decayFactor)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration / Double(shakeCount))) {
                    switch starIndex {
                    case 1: star1Shake = shake
                    case 2: star2Shake = shake
                    case 3: star3Shake = shake
                    default: break
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeOut(duration: 0.3)) {
                switch starIndex {
                case 1: star1Shake = 0
                case 2: star2Shake = 0
                case 3: star3Shake = 0
                default: break
                }
            }
        }
    }

    // MARK: - UI Components
    private var exitButton: some View {
        Button {
            onBackToHomeTapped?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "exit-button",
                pressedImage: "exit-button",
                height: 65.0
            )
        )
    }

    private var heartsEarnedView: some View {
        ZStack {
            Image("lives-gained-background")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 80)
            Image("life-heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 45)
            VStack(alignment: .trailing) {
                Text("X1")
                    .font(.custom("helsinki", size: 25))
                    .padding(.leading, 35.0)
                    .scaleEffect(heartTextScale)
                    .opacity(heartTextOpacity)
                Spacer()
            }
        }
        .frame(maxHeight: 80.0)
        .onAppear {
            startHeartTextAnimation()
        }
    }
    
    private func startHeartTextAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                heartTextScale = 1.0
                heartTextOpacity = 1.0
            }
        }
    }
    
    private var resetButton: some View {
        Button {
            SoundManager.shared.playButtonTapSound()
            onResetGame?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "reset-game-button",
                pressedImage: "reset-game-button",
                height: 45.0
            )
        )
    }
    
    private var levelsButton: some View {
        Button {
            SoundManager.shared.playButtonTapSound()
            onBackToLevelsTapped?()
        } label: {
            EmptyView()
        }
        .buttonStyle(
            ImageButtonStyle(
                normalImage: "levels-button-3",
                pressedImage: "levels-button-3",
                height: 45.0
            )
        )
    }
}

struct StarView: View {
    let imageName: String
    let size: CGFloat
    let scale: CGFloat
    let offset: CGPoint
    let shake: CGFloat
    let rotation: Double
    let isEarned: Bool
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: offset.x + shake, y: offset.y)
            .opacity(isEarned ? 1.0 : 0.3)
            .shadow(color: isEarned ? .yellow : .clear, radius: scale > 1.0 ? 15 : 0)
    }
}
