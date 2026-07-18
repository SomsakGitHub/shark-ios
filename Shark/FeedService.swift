import Foundation

class FeedService {
    static let shared = FeedService()
    private let baseURL = "https://marauders-api.khamthan02.workers.dev/feed"
    
    private init() {}
    
    func fetchFeed() async throws -> FeedResponse {
        guard let url = URL(string: baseURL) else {
            throw FeedError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FeedError.serverError
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(FeedResponse.self, from: data)
    }
}

enum FeedError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError:
            return "Server error"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
