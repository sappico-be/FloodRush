import SwiftUI

struct APIPlayerStats: Codable {
    let totalScore: Int?
    let totalStars: Int?
    let levelsCompleted: Int?
    let unlockedLevels: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case totalScore = "total_score"
        case totalStars = "total_stars"
        case levelsCompleted = "levels_completed"
        case unlockedLevels = "unlocked_levels"
    }
    
    // Helper computed properties with defaults
    var safeScore: Int { totalScore ?? 0 }
    var safeStars: Int { totalStars ?? 0 }
    var safeLevelsCompleted: Int { levelsCompleted ?? 0 }
    var safeUnlockedLevels: [Int] { unlockedLevels ?? [1] }
}
