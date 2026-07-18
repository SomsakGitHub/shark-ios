import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(statusCode: Int)
    case unauthorized
    case forbidden
    case notFound
    case networkError(Error)
    case timeout
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingFailed(let error):
            return "Failed to decode: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error (\(statusCode))"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out"
        case .unknown:
            return "An unknown error occurred"
        }
    }

    init(from statusCode: Int) {
        switch statusCode {
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 500...599: self = .serverError(statusCode: statusCode)
        default: self = .serverError(statusCode: statusCode)
        }
    }
}
