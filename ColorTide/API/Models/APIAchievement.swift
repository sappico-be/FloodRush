import SwiftUI

struct APIAchievement: Codable {
    let id: Int
    let achievementKey: String
    let name: String
    let description: String
    let category: String
    let targetValue: Int?
    let points: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, category, points
        case achievementKey = "achievement_key"
        case targetValue = "target_value"
    }
}
