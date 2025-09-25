import SwiftUI

struct APIStarThreshold: Codable {
    let oneStar: Int
    let twoStars: Int
    let threeStars: Int
    
    enum CodingKeys: String, CodingKey {
        case oneStar = "one_star"
        case twoStars = "two_stars"
        case threeStars = "three_stars"
    }
}
