import SwiftUI

struct ParticleData: Identifiable {
    let id = UUID()
    let points: Int
    let startPosition: CGPoint
    let endPosition: CGPoint
    var currentPosition: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 1.2
    
    init(points: Int, startPosition: CGPoint, endPosition: CGPoint) {
        self.points = points
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.currentPosition = startPosition
    }
}
