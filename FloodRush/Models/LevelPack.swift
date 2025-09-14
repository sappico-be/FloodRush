import SwiftUI

struct LevelPack {
    let id: Int
    let name: String
    let emoji: String
    let baseGridSize: Int
    let baseColorCount: Int
    let levels: [GameLevel]
    let isUnlocked: Bool
    
    var displayName: String {
        return "\(emoji) \(name)"
    }
}
