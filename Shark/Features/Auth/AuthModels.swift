import Foundation

struct AuthUser: Identifiable {
    let id: String
    let email: String?
    let name: String?
}

enum AuthError: LocalizedError {
    case serverError
    case invalidToken
    case userCancelled

    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Server error"
        case .invalidToken:
            return "Invalid token"
        case .userCancelled:
            return "User cancelled"
        }
    }
}
