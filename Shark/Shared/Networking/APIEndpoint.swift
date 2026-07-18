import Foundation

enum APIEndpoint {
    case feed
    case authApple
    case likeVideo(id: String)
    case commentVideo(id: String)
    case uploadVideo
    case userProfile(id: String)
    case search(query: String)

    private static let baseURL = "https://marauders-api.khamthan02.workers.dev"

    var path: String {
        switch self {
        case .feed:
            return "/feed"
        case .authApple:
            return "/auth/apple"
        case .likeVideo(let id):
            return "/videos/\(id)/like"
        case .commentVideo(let id):
            return "/videos/\(id)/comments"
        case .uploadVideo:
            return "/videos/upload"
        case .userProfile(let id):
            return "/users/\(id)"
        case .search:
            return "/search"
        }
    }

    var url: URL? {
        URL(string: Self.baseURL + path)
    }

    var method: HTTPMethod {
        switch self {
        case .feed, .userProfile, .search, .commentVideo:
            return .get
        case .authApple, .likeVideo, .uploadVideo:
            return .post
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
