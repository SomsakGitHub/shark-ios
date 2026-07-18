import Foundation

struct AuthService {
    private static let baseURL = "https://marauders-api.khamthan02.workers.dev"

    static func authenticate(
        identityToken: String,
        email: String?,
        fullName: PersonNameComponents?
    ) async throws -> AuthResponse {
        // TODO: Replace with real backend call when /auth/apple is ready
        // var request = URLRequest(url: URL(string: "\(baseURL)/auth/apple")!)
        // request.httpMethod = "POST"
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // let body: [String: Any] = [
        //     "identityToken": identityToken,
        //     "email": email ?? "",
        //     "fullName": [
        //         "givenName": fullName?.givenName ?? "",
        //         "familyName": fullName?.familyName ?? ""
        //     ]
        // ]
        // request.httpBody = try JSONSerialization.data(withJSONObject: body)
        // let (data, response) = try await URLSession.shared.data(for: request)
        // guard let httpResponse = response as? HTTPURLResponse,
        //       httpResponse.statusCode == 200 else {
        //     throw AuthError.serverError
        // }
        // return try JSONDecoder().decode(AuthResponse.self, from: data)

        // Mock response
        try await Task.sleep(for: .seconds(1))
        let name = if let fullName {
            "\(fullName.givenName ?? "") \(fullName.familyName ?? "")".trimmingCharacters(in: .whitespaces)
        } else {
            "User"
        }
        return AuthResponse(
            token: "mock_jwt_token_\(UUID().uuidString)",
            email: email,
            name: name.isEmpty ? "User" : name,
            userId: UUID().uuidString
        )
    }
}
