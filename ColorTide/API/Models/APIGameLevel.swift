import SwiftUI

struct APIGameLevel: Codable {
    let id: Int
    let levelNumber: Int
    let displayName: String
    
    // Optional fields - not always present in all API responses
    let gridSize: Int?
    let fruitCount: Int?
    let startPosition: APIGridPosition?
    let targetFruit: String?
    let targetMoves: Int?
    let baseScore: Int?
    let predefinedGrid: [[String]]?
    let starThresholds: APIStarThreshold?
    
    enum CodingKeys: String, CodingKey {
        case id
        case levelNumber = "level_number"
        case displayName = "display_name"
        case gridSize = "grid_size"
        case fruitCount = "fruit_count"
        case startPosition = "start_position"
        case targetFruit = "target_fruit"
        case targetMoves = "target_moves"
        case baseScore = "base_score"
        case predefinedGrid = "predefined_grid"
        case starThresholds = "star_thresholds"
    }
    
    // Safe accessors with defaults
    var safeGridSize: Int { gridSize ?? 6 }
    var safeFruitCount: Int { fruitCount ?? 3 }
    var safeStartPosition: APIGridPosition {
        startPosition ?? APIGridPosition(row: 0, col: 0)
    }
    var safeTargetFruit: String? { targetFruit } 
    var safeTargetMoves: Int { targetMoves ?? 10 }
    var safeBaseScore: Int { baseScore ?? 8000 }
    var safePredefinedGrid: [[String]] { predefinedGrid ?? [] }
}
