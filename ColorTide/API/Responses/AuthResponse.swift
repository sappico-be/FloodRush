import SwiftUI

struct AuthResponse: Codable {
    let player: APIPlayer
    let token: String
    let isNewPlayer: Bool
    
    enum CodingKeys: String, CodingKey {
        case player, token
        case isNewPlayer = "is_new_player"
    }
}
