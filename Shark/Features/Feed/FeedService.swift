import Foundation

class FeedService {
    static let shared = FeedService()

    private init() {}

    func fetchFeed() async throws -> FeedResponse {
        try await NetworkManager.shared.request(.feed, responseType: FeedResponse.self)
    }
}
