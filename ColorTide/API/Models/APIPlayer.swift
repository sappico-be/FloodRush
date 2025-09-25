import SwiftUI

struct APIPlayer: Codable {
    let id: Int
    let deviceId: String
    let username: String?
    let totalScore: Int?
    let totalStars: Int?
    let levelsCompleted: Int?
    let currentLives: Int?
    let maxLives: Int?
    let unlockedLevels: [Int]?
    let canPlay: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, username
        case deviceId = "device_id"
        case totalScore = "total_score"
        case totalStars = "total_stars"
        case levelsCompleted = "levels_completed"
        case currentLives = "current_lives"
        case maxLives = "max_lives"
        case unlockedLevels = "unlocked_levels"
        case canPlay = "can_play"
    }
    
    // Helper computed properties with defaults
    var safeScore: Int { totalScore ?? 0 }
    var safeStars: Int { totalStars ?? 0 }
    var safeLevelsCompleted: Int { levelsCompleted ?? 0 }
    var safeCurrentLives: Int { currentLives ?? 3 }
    var safeMaxLives: Int { maxLives ?? 3 }
    var safeUnlockedLevels: [Int] { unlockedLevels ?? [1] }
    var safeCanPlay: Bool { canPlay ?? true }
}
