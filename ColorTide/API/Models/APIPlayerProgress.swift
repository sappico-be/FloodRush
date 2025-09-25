import SwiftUI

struct APIPlayerProgress: Codable {
    let id: Int
    let gameLevel: APIGameLevel
    let bestScore: Int?
    let starsEarned: Int?
    let bestMoves: Int?
    let completed: Bool?
    let usedUndo: Bool?
    let completionCount: Int?
    let efficiency: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, completed, efficiency
        case gameLevel = "game_level"
        case bestScore = "best_score"
        case starsEarned = "stars_earned"
        case bestMoves = "best_moves"
        case usedUndo = "used_undo"
        case completionCount = "completion_count"
    }
    
    // Safe accessors
    var safeBestScore: Int { bestScore ?? 0 }
    var safeStarsEarned: Int { starsEarned ?? 0 }
    var safeBestMoves: Int { bestMoves ?? 0 }
    var safeCompleted: Bool { completed ?? false }
    var safeUsedUndo: Bool { usedUndo ?? false }
}
