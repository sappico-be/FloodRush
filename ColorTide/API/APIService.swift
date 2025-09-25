import SwiftUI
import Combine
import Foundation

// MARK: - API Service
class ColorTideAPIService: ObservableObject {
    static let shared = ColorTideAPIService()
    
    private let baseURL = "https://api.colortide-game.com/api/v1"
    @Published private(set) var authToken: String?
    @Published private(set) var currentPlayer: APIPlayer?
    @Published private(set) var isLoading = false
    
    private init() {
        loadStoredAuth()
    }
    
    // MARK: - Auth Management
    private func loadStoredAuth() {
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            self.authToken = token
        }
    }
    
    private func saveAuth(token: String, player: APIPlayer) {
        self.authToken = token
        self.currentPlayer = player
        UserDefaults.standard.set(token, forKey: "auth_token")
        
        // Save player data
        if let encoded = try? JSONEncoder().encode(player) {
            UserDefaults.standard.set(encoded, forKey: "current_player")
        }
    }
    
    // MARK: - Network Helper (change private to internal)
    func makeRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        responseType: T.Type
    ) -> AnyPublisher<T, Error> {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .handleEvents(receiveSubscription: { _ in
                DispatchQueue.main.async {
                    self.isLoading = true
                }
            }, receiveCompletion: { _ in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            })
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response in
                if response.success, let data = response.data {
                    return data
                } else {
                    throw APIError.serverError(response.message ?? response.error ?? "Unknown error")
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Authentication
    func authenticatePlayer() -> AnyPublisher<AuthResponse, Error> {
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let username = "Player" // You can make this customizable
        
        let body = [
            "device_id": deviceId,
            "username": username
        ]
        
        return makeRequest(
            endpoint: "auth/register-or-login",
            method: "POST",
            body: body,
            responseType: AuthResponse.self
        )
        .handleEvents(receiveOutput: { [weak self] response in
            self?.saveAuth(token: response.token, player: response.player)
        })
        .eraseToAnyPublisher()
    }
    
    // MARK: - Levels
    func getAllLevels() -> AnyPublisher<[APIGameLevel], Error> {
        return makeRequest(
            endpoint: "levels",
            responseType: [APIGameLevel].self
        )
    }
    
    func getLevel(number: Int) -> AnyPublisher<APIGameLevel, Error> {
        return makeRequest(
            endpoint: "levels/\(number)",
            responseType: APIGameLevel.self
        )
    }
    
    // MARK: - Progress
    func completeLevel(
        levelNumber: Int,
        score: Int,
        moves: Int,
        stars: Int,
        usedUndo: Bool
    ) -> AnyPublisher<CompleteLevelResponse, Error> {
        
        let body: [String: Any] = [
            "level_number": levelNumber,
            "score": score,
            "moves": moves,
            "stars": stars,
            "used_undo": usedUndo
        ]
        
        return makeRequest(
            endpoint: "progress/complete-level",
            method: "POST",
            body: body,
            requiresAuth: true,
            responseType: CompleteLevelResponse.self
        )
        .handleEvents(receiveOutput: { [weak self] response in
            // Update current player with new stats
            if let currentPlayer = self?.currentPlayer {
                self?.currentPlayer = APIPlayer(
                    id: currentPlayer.id,
                    deviceId: currentPlayer.deviceId,
                    username: currentPlayer.username,
                    totalScore: response.playerStats.safeScore,
                    totalStars: response.playerStats.safeStars,
                    levelsCompleted: response.playerStats.safeLevelsCompleted,
                    currentLives: currentPlayer.safeCurrentLives,
                    maxLives: currentPlayer.safeMaxLives,
                    unlockedLevels: response.playerStats.safeUnlockedLevels,
                    canPlay: currentPlayer.safeCanPlay
                )
            }
        })
        .eraseToAnyPublisher()
    }
    
    // MARK: - Achievements
    func getAchievements() -> AnyPublisher<[APIAchievement], Error> {
        return makeRequest(
            endpoint: "achievements",
            responseType: [APIAchievement].self
        )
    }
    
    // MARK: - Player Stats
    func refreshPlayerProfile() -> AnyPublisher<APIPlayer, Error> {
        return makeRequest(
            endpoint: "auth/profile",
            requiresAuth: true,
            responseType: APIPlayer.self
        )
        .handleEvents(receiveOutput: { [weak self] player in
            self?.currentPlayer = player
        })
        .eraseToAnyPublisher()
    }
    
    // MARK: - Progress
    func getPlayerProgress() -> AnyPublisher<[APIPlayerProgress], Error> {
        return makeRequest(
            endpoint: "progress",
            requiresAuth: true,
            responseType: [APIPlayerProgress].self
        )
    }
}

// MARK: - Errors
enum APIError: LocalizedError {
    case invalidURL
    case notAuthenticated
    case serverError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .notAuthenticated:
            return "Not authenticated"
        case .serverError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
