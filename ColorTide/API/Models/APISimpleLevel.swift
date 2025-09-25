import SwiftUI

struct APISimpleLevel: Codable {
    let id: Int
    let levelNumber: Int
    let displayName: String
    let targetMoves: Int?
    let baseScore: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case levelNumber = "level_number"
        case displayName = "display_name"
        case targetMoves = "target_moves"
        case baseScore = "base_score"
    }
    
    var safeTargetMoves: Int { targetMoves ?? 10 }
    var safeBaseScore: Int { baseScore ?? 8000 }
}
