import SwiftUI

// Extension to convert string to Fruit enum
extension Fruit {
    static func from(string: String) -> Fruit {
        switch string.lowercased() {
        case "nut":
            return .nut
        case "cherry":
            return .cherry
        case "strawberry":
            return .strawberry
        case "muchroom":
            return .muchroom
        case "berry":
            return .berry
        case "clover":
            return .clover
        case "grapes":
            return .grapes
        default:
            return .nut // fallback
        }
    }
    
    var stringValue: String {
        switch self {
        case .nut: return "nut"
        case .cherry: return "cherry"
        case .strawberry: return "strawberry"
        case .muchroom: return "muchroom"
        case .berry: return "berry"
        case .clover: return "clover"
        case .grapes: return "grapes"
        }
    }
    
    // NEW: Display names for target fruit
    var displayName: String {
        switch self {
        case .nut: return "Nuts"
        case .cherry: return "Cherries"
        case .strawberry: return "Strawberries"
        case .muchroom: return "Mushrooms"
        case .berry: return "Berries"
        case .clover: return "Clovers"
        case .grapes: return "Grapes"
        }
    }
}
