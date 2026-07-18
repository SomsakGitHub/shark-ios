import Foundation

actor NetworkManager {
    static let shared = NetworkManager()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainService.read(key: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingFailed(error)
                }
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            default:
                throw APIError(from: httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.networkError(error)
        }
    }

    func request<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B,
        responseType: T.Type
    ) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainService.read(key: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try encoder.encode(body)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw APIError.decodingFailed(error)
                }
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            default:
                throw APIError(from: httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.networkError(error)
        }
    }

    func requestVoid(
        _ endpoint: APIEndpoint
    ) async throws {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainService.read(key: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown
            }

            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            default:
                throw APIError(from: httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.networkError(error)
        }
    }
}
