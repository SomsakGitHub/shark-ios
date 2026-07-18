import Foundation

struct FeedResponse: Codable {
    let videos: [FeedVideo]
    let nextCursor: String?
}

struct FeedVideo: Codable, Identifiable {
    let id: String
    let userId: String
    let status: String
    let originalObjectKey: String
    let playbackManifestUrl: String
    let durationMs: Int
    let width: Int
    let height: Int
    let thumbnailUrl: String
    let createdAt: String
    let updatedAt: String
    let user: FeedUser
    let likeCount: Int
}

struct FeedUser: Codable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let avatarUrl: String
}
