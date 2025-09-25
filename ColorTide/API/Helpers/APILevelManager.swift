import SwiftUI
import Combine

class APILevelManager: ObservableObject {
    @Published var currentLevel: GameLevel
    @Published var allLevels: [GameLevel] = []
    @Published var completedLevels: Set<Int> = []
    @Published var unlockedLevels: Set<Int> = []
    @Published var totalScore: Int = 0
    @Published var totalStarsEarned: Int = 0
    @Published var levelsCompleted: Int = 0
    @Published var levelScores: [Int: Int] = [:]
    @Published var levelStars: [Int: Int] = [:]
    @Published var levelMoves: [Int: Int] = [:]
    @Published var levelUndoUsed: [Int: Bool] = [:]
    @Published var currentLives: Int = 3
    @Published var maxLives: Int = 3
    
    // Loading states
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiService = ColorTideAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with a placeholder level
        self.currentLevel = GameLevel(
            id: 1,
            gridSize: 6,
            fruitCount: 3,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 8,
            baseScore: 8000,
            predefinedGrid: [[.nut]]
        )
        
        // Start authentication and data loading
        initializeWithAPI()
    }
    
    private func initializeWithAPI() {
        // First authenticate
        apiService.authenticatePlayer()
            .flatMap { [weak self] authResponse -> AnyPublisher<[APIGameLevel], Error> in
                // Update player stats
                DispatchQueue.main.async {
                    self?.updatePlayerStats(from: authResponse.player)
                }
                // Then load levels
                return self?.apiService.getAllLevels() ?? Empty().eraseToAnyPublisher()
            }
            .flatMap { [weak self] apiLevels -> AnyPublisher<[APIPlayerProgress], Error> in
                // Store levels first
                DispatchQueue.main.async {
                    self?.loadLevelsFromAPI(apiLevels)
                }
                // Then load player progress
                return self?.loadPlayerProgress() ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                        print("❌ API Error: \(error)")
                        // Fallback to local data if API fails
                        self?.initializeWithFallbackData()
                    }
                },
                receiveValue: { [weak self] progressData in
                    self?.updateProgressFromAPI(progressData)
                    self?.isLoading = false
                    print("✅ Loaded levels and progress from API")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load Player Progress from API
    private func loadPlayerProgress() -> AnyPublisher<[APIPlayerProgress], Error> {
        return apiService.getPlayerProgress()
            .catch { [weak self] error -> AnyPublisher<[APIPlayerProgress], Error> in
                print("⚠️ Progress endpoint failed, using fallback")
                // Fallback: create progress based on unlocked levels
                return self?.createProgressFromUnlockedLevels() ??
                       Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Update Progress from API
    private func updateProgressFromAPI(_ progressList: [APIPlayerProgress]) {
        // Clear existing progress
        levelScores.removeAll()
        levelStars.removeAll()
        levelMoves.removeAll()
        levelUndoUsed.removeAll()
        completedLevels.removeAll()
        
        // Update with API data
        for progress in progressList {
            let levelId = progress.gameLevel.levelNumber
            
            if progress.safeCompleted {
                completedLevels.insert(levelId)
                levelScores[levelId] = progress.safeBestScore
                levelStars[levelId] = progress.safeStarsEarned
                levelMoves[levelId] = progress.safeBestMoves
                levelUndoUsed[levelId] = progress.safeUsedUndo
            }
        }
        
        print("📊 Updated progress for \(completedLevels.count) completed levels")
        print("⭐ Stars per level: \(levelStars)")
    }
    
    private func createProgressFromUnlockedLevels() -> AnyPublisher<[APIPlayerProgress], Error> {
        // Simple fallback: assume all unlocked levels except the last are completed
        let completedLevelIds = Array(unlockedLevels).sorted().dropLast()
        let progressData: [APIPlayerProgress] = []  // Empty for now, will be populated by actual progress
        
        return Just(progressData).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    private func loadLevelsFromAPI(_ apiLevels: [APIGameLevel]) {
        self.allLevels = apiLevels.map { GameLevel(from: $0) }
        
        if let firstLevel = allLevels.first {
            self.currentLevel = firstLevel
        }
        
        self.isLoading = false
        print("✅ Loaded \(allLevels.count) levels from API")
    }
    
    private func updatePlayerStats(from apiPlayer: APIPlayer) {
        self.totalScore = apiPlayer.safeScore
        self.totalStarsEarned = apiPlayer.safeStars
        self.levelsCompleted = apiPlayer.safeLevelsCompleted
        self.currentLives = apiPlayer.safeCurrentLives
        self.maxLives = apiPlayer.safeMaxLives
        self.unlockedLevels = Set(apiPlayer.safeUnlockedLevels)
        
        print("👤 Player stats updated - Score: \(self.totalScore), Stars: \(self.totalStarsEarned)")
        print("🔓 Unlocked levels: \(self.unlockedLevels)")
    }
    
    private func initializeWithFallbackData() {
        // Use your original predefined levels as fallback
        self.allLevels = Self.createPredefinedLevels()
        self.currentLevel = allLevels[0]
        self.unlockedLevels = [1]
        self.isLoading = false
        print("⚠️ Using fallback data - API unavailable")
    }
    
    // MARK: - Level Management (API-integrated)
    func selectLevel(_ level: GameLevel) {
        currentLevel = level
    }
    
    func completeLevel(_ levelId: Int, withScore score: Int, stars: Int, moves: Int, usedUndo: Bool) {
        // Optimistic update
        let wasAlreadyCompleted = completedLevels.contains(levelId)
        
        if !wasAlreadyCompleted {
            completedLevels.insert(levelId)
            totalScore += score
            totalStarsEarned += stars
            levelsCompleted += 1
            levelScores[levelId] = score
            levelStars[levelId] = stars
            levelMoves[levelId] = moves
            levelUndoUsed[levelId] = usedUndo
            
            // Unlock next level
            if let currentIndex = allLevels.firstIndex(where: { $0.id == levelId }) {
                if currentIndex + 1 < allLevels.count {
                    let nextLevel = allLevels[currentIndex + 1]
                    unlockedLevels.insert(nextLevel.id)
                }
            }
        }
        
        // Sync with API
        apiService.completeLevel(
            levelNumber: levelId,
            score: score,
            moves: moves,
            stars: stars,
            usedUndo: usedUndo
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to sync with server: \(error.localizedDescription)"
                    print("❌ Failed to sync level completion: \(error)")
                }
            },
            receiveValue: { [weak self] response in
                // Update with server response
                self?.totalScore = response.playerStats.safeScore
                self?.totalStarsEarned = response.playerStats.safeStars
                self?.levelsCompleted = response.playerStats.safeLevelsCompleted
                self?.unlockedLevels = Set(response.playerStats.safeUnlockedLevels)
                
                // Update level-specific stats
                let levelId = response.progress.gameLevel.levelNumber
                self?.levelScores[levelId] = response.progress.safeBestScore
                self?.levelStars[levelId] = response.progress.safeStarsEarned
                self?.levelMoves[levelId] = response.progress.safeBestMoves
                
                print("✅ Level completion synced with server")
                print("📊 Stats - Score: \(response.playerStats.safeScore), Stars: \(response.playerStats.safeStars), Levels: \(response.playerStats.safeLevelsCompleted)")
                print("🔓 Unlocked levels: \(response.playerStats.safeUnlockedLevels)")
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - All your existing methods stay the same
    func nextLevel() -> GameLevel? {
        guard let currentIndex = allLevels.firstIndex(where: { $0.id == currentLevel.id }) else {
            return nil
        }
        
        if currentIndex + 1 < allLevels.count {
            return allLevels[currentIndex + 1]
        }
        
        return nil
    }
    
    func getLevel(byId id: Int) -> GameLevel? {
        return allLevels.first { $0.id == id }
    }
    
    func getNextUnlockedLevel() -> GameLevel? {
        return allLevels.first { level in
            unlockedLevels.contains(level.id) && !completedLevels.contains(level.id)
        } ?? allLevels.first { level in
            unlockedLevels.contains(level.id)
        }
    }

    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }
    
    func isLevelCompleted(_ levelId: Int) -> Bool {
        return completedLevels.contains(levelId)
    }
    
    func getStarsForLevel(_ levelId: Int) -> Int {
        return levelStars[levelId] ?? 0
    }
    
    func getScoreForLevel(_ levelId: Int) -> Int {
        return levelScores[levelId] ?? 0
    }
    
    func getMovesForLevel(_ levelId: Int) -> Int {
        return levelMoves[levelId] ?? 0
    }
    
    func didUseUndoForLevel(_ levelId: Int) -> Bool {
        return levelUndoUsed[levelId] ?? false
    }
    
    // MARK: - Lives System
    func loseLife() -> Bool {
        currentLives = max(0, currentLives - 1)
        return currentLives > 0
    }
    
    func resetLives() {
        currentLives = maxLives
    }
    
    func hasLivesRemaining() -> Bool {
        return currentLives > 0
    }
    
    // MARK: - Leaderboards (API integrated)
    func showLeaderboards() {
        // For now, this could show an in-app leaderboard view
        print("🏆 Showing leaderboards...")
    }
    
    func showAchievements() {
        print("🏅 Showing achievements...")
    }
    
    // MARK: - Utility Functions
    func getLevelsForMap(startIndex: Int = 0, count: Int = 20) -> [GameLevel] {
        let endIndex = min(startIndex + count, allLevels.count)
        guard startIndex < allLevels.count && startIndex >= 0 else { return [] }
        return Array(allLevels[startIndex..<endIndex])
    }
    
    func getTotalLevelCount() -> Int {
        return allLevels.count
    }
    
    // MARK: - Fallback data (keep your original method)
    private static func createPredefinedLevels() -> [GameLevel] {
        // Your original level creation code here
        var levels: [GameLevel] = []
        
        // Level 1: Tutorial level - easy pattern
        levels.append(GameLevel(
            id: 1,
            gridSize: 6,
            fruitCount: 3,
            startPosition: GridPosition(row: 0, col: 0),
            targetFruit: nil,
            targetMoves: 8,
            baseScore: 8000,
            predefinedGrid: [
                [.nut, .cherry, .nut, .cherry, .nut, .cherry],
                [.cherry, .nut, .cherry, .nut, .cherry, .nut],
                [.nut, .cherry, .strawberry, .strawberry, .cherry, .nut],
                [.cherry, .nut, .strawberry, .strawberry, .nut, .cherry],
                [.nut, .cherry, .nut, .cherry, .nut, .cherry],
                [.cherry, .nut, .cherry, .nut, .cherry, .nut]
            ]
        ))
        
        // Add more levels as needed...
        
        return levels
    }
}
