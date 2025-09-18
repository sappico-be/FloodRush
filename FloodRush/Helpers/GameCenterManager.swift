import SwiftUI
import GameKit
import Combine

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var localPlayer: GKLocalPlayer?
    @Published var isGameCenterEnabled = false
    
    // MARK: - Leaderboard IDs (Deze moet je configureren in App Store Connect)
    struct LeaderboardIDs {
        static let totalScore = "total_score_leaderboard"
        static let totalStars = "total_stars_leaderboard"
        static let levelsCompleted = "levels_completed_leaderboard"
        static let averageMoves = "average_moves_leaderboard"
        
        // Per-level leaderboards (best score per level)
        static func levelBestScore(levelId: Int) -> String {
            return "level_\(levelId)_best_score"
        }
        
        static func levelFewestMoves(levelId: Int) -> String {
            return "level_\(levelId)_fewest_moves"
        }
    }
    
    // MARK: - Achievement IDs (Deze moet je configureren in App Store Connect)
    struct AchievementIDs {
        static let firstLevel = "first_level_complete"
        static let levelMaster5 = "complete_5_levels"
        static let levelMaster10 = "complete_10_levels"
        static let levelMaster25 = "complete_25_levels"
        static let perfectionist5 = "perfect_5_levels" // 5 levels with 3 stars
        static let perfectionist10 = "perfect_10_levels"
        static let speedRunner = "complete_level_under_target"
        static let starCollector25 = "collect_25_stars"
        static let starCollector50 = "collect_50_stars"
        static let starCollector100 = "collect_100_stars"
        static let noMistakes = "complete_without_undo" // Complete level without using undo
    }
    
    private override init() {
        super.init()
        authenticateLocalPlayer()
    }
    
    // MARK: - Authentication
    func authenticateLocalPlayer() {
        localPlayer = GKLocalPlayer.local
        
        localPlayer?.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if let viewController = viewController {
                    // Present authentication view controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(viewController, animated: true)
                    }
                } else if let error = error {
                    print("GameCenter authentication failed: \(error.localizedDescription)")
                    self?.isAuthenticated = false
                    self?.isGameCenterEnabled = false
                } else {
                    // Authentication successful
                    self?.isAuthenticated = self?.localPlayer?.isAuthenticated ?? false
                    self?.isGameCenterEnabled = true
                    print("GameCenter authenticated successfully!")
                    
                    // Load existing achievements on login
                    self?.loadAchievements()
                }
            }
        }
    }
    
    // MARK: - Leaderboards (iOS 14+ API)
    func submitScore(_ score: Int, category: String, completion: ((Bool) -> Void)? = nil) {
        guard isAuthenticated else {
            print("Not authenticated with GameCenter")
            completion?(false)
            return
        }
        
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    score,
                    context: 0,
                    player: localPlayer!,
                    leaderboardIDs: [category]
                )
                
                DispatchQueue.main.async {
                    print("Score submitted successfully: \(score) to \(category)")
                    completion?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Score submission failed: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - Convenience Score Submission Methods
    func submitLevelScore(levelId: Int, score: Int, moves: Int) {
        // Submit best score for this level
        submitScore(score, category: LeaderboardIDs.levelBestScore(levelId: levelId))
        
        // Submit fewest moves for this level
        submitScore(moves, category: LeaderboardIDs.levelFewestMoves(levelId: levelId))
    }
    
    func submitOverallStats(totalScore: Int, totalStars: Int, levelsCompleted: Int) {
        submitScore(totalScore, category: LeaderboardIDs.totalScore)
        submitScore(totalStars, category: LeaderboardIDs.totalStars)
        submitScore(levelsCompleted, category: LeaderboardIDs.levelsCompleted)
        
        // Calculate average moves (if you track this)
        // let averageMoves = calculateAverageMoves()
        // submitScore(averageMoves, category: LeaderboardIDs.averageMoves)
    }
    
    // MARK: - Achievements (iOS 14+ API)
    private var loadedAchievements: [String: GKAchievement] = [:]
    
    func loadAchievements() {
        Task {
            do {
                let achievements = try await GKAchievement.loadAchievements()
                
                DispatchQueue.main.async { [weak self] in
                    // Store loaded achievements
                    achievements.forEach { achievement in
                        self?.loadedAchievements[achievement.identifier] = achievement
                    }
                    
                    print("Loaded \(achievements.count) achievements")
                }
            } catch {
                print("Failed to load achievements: \(error.localizedDescription)")
            }
        }
    }
    
    func unlockAchievement(_ identifier: String, percentComplete: Double = 100.0, completion: ((Bool) -> Void)? = nil) {
        guard isAuthenticated else {
            completion?(false)
            return
        }
        
        let achievement: GKAchievement
        
        // Use existing achievement or create new one
        if let existingAchievement = loadedAchievements[identifier] {
            achievement = existingAchievement
        } else {
            achievement = GKAchievement(identifier: identifier)
            loadedAchievements[identifier] = achievement
        }
        
        // Don't report if already completed
        if achievement.isCompleted {
            completion?(true)
            return
        }
        
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        Task {
            do {
                try await GKAchievement.report([achievement])
                
                DispatchQueue.main.async {
                    print("Achievement unlocked: \(identifier)")
                    completion?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    print("Achievement unlock failed: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - Achievement Progress Tracking
    func updateProgressAchievement(_ identifier: String, currentValue: Int, targetValue: Int) {
        let percentComplete = min(100.0, (Double(currentValue) / Double(targetValue)) * 100.0)
        unlockAchievement(identifier, percentComplete: percentComplete)
    }
    
    // MARK: - UI Presentation (iOS 14+ API)
    func showLeaderboards(completion: (() -> Void)? = nil) {
        guard isAuthenticated else {
            print("Not authenticated with GameCenter")
            completion?()
            return
        }
        
        let leaderboardsVC = GKGameCenterViewController(leaderboardID: LeaderboardIDs.totalScore, playerScope: .global, timeScope: .allTime)
        leaderboardsVC.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(leaderboardsVC, animated: true) {
                completion?()
            }
        }
    }
    
    func showAchievements(completion: (() -> Void)? = nil) {
        guard isAuthenticated else {
            print("Not authenticated with GameCenter")
            completion?()
            return
        }
        
        let achievementsVC = GKGameCenterViewController(state: .achievements)
        achievementsVC.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(achievementsVC, animated: true) {
                completion?()
            }
        }
    }
    
    // NIEUW: Show specific leaderboard
    func showSpecificLeaderboard(_ leaderboardID: String, completion: (() -> Void)? = nil) {
        guard isAuthenticated else {
            print("Not authenticated with GameCenter")
            completion?()
            return
        }
        
        let leaderboardVC = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        leaderboardVC.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(leaderboardVC, animated: true) {
                completion?()
            }
        }
    }
    
    // MARK: - Game-Specific Helper Methods
    func handleLevelCompletion(
        levelId: Int,
        score: Int,
        moves: Int,
        stars: Int,
        usedUndo: Bool,
        targetMoves: Int,
        totalLevelsCompleted: Int,
        totalStars: Int,
        totalScore: Int
    ) {
        // Submit scores
        submitLevelScore(levelId: levelId, score: score, moves: moves)
        submitOverallStats(totalScore: totalScore, totalStars: totalStars, levelsCompleted: totalLevelsCompleted)
        
        // Handle achievements
        handleAchievements(
            levelId: levelId,
            moves: moves,
            stars: stars,
            usedUndo: usedUndo,
            targetMoves: targetMoves,
            totalLevelsCompleted: totalLevelsCompleted,
            totalStars: totalStars
        )
    }
    
    private func handleAchievements(
        levelId: Int,
        moves: Int,
        stars: Int,
        usedUndo: Bool,
        targetMoves: Int,
        totalLevelsCompleted: Int,
        totalStars: Int
    ) {
        // First level completion
        if levelId == 1 {
            unlockAchievement(AchievementIDs.firstLevel)
        }
        
        // Level completion milestones
        if totalLevelsCompleted >= 25 {
            unlockAchievement(AchievementIDs.levelMaster25)
        } else if totalLevelsCompleted >= 10 {
            unlockAchievement(AchievementIDs.levelMaster10)
        } else if totalLevelsCompleted >= 5 {
            unlockAchievement(AchievementIDs.levelMaster5)
        }
        
        // Star collection
        if totalStars >= 100 {
            unlockAchievement(AchievementIDs.starCollector100)
        } else if totalStars >= 50 {
            unlockAchievement(AchievementIDs.starCollector50)
        } else if totalStars >= 25 {
            unlockAchievement(AchievementIDs.starCollector25)
        }
        
        // Perfect levels (3 stars)
        if stars == 3 {
            // Count perfect levels (you'd need to track this in LevelManager)
            // updateProgressAchievement(AchievementIDs.perfectionist10, currentValue: perfectLevels, targetValue: 10)
        }
        
        // Speed runner (under target moves)
        if moves <= targetMoves {
            unlockAchievement(AchievementIDs.speedRunner)
        }
        
        // No mistakes (didn't use undo)
        if !usedUndo {
            unlockAchievement(AchievementIDs.noMistakes)
        }
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
