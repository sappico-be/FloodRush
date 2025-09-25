import SwiftUI

struct CompleteLevelResponse: Codable {
    let progress: APIPlayerProgress
    let wasFirstCompletion: Bool
    let wasImprovement: Bool
    let nextLevelUnlocked: Bool
    let playerStats: APIPlayerStats
    
    enum CodingKeys: String, CodingKey {
        case progress
        case wasFirstCompletion = "was_first_completion"
        case wasImprovement = "was_improvement"
        case nextLevelUnlocked = "next_level_unlocked"
        case playerStats = "player_stats"
    }
}
