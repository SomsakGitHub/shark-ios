import Foundation

struct AuthService {
    static func authenticate(
        identityToken: String,
        email: String?,
        fullName: PersonNameComponents?
    ) async throws -> AuthResponse {
        // TODO: Replace with real backend call when /auth/apple is ready
        // struct AuthAppleRequest: Encodable {
        //     let identityToken: String
        //     let email: String?
        //     let fullName: FullName?
        //     struct FullName: Encodable {
        //         let givenName: String?
        //         let familyName: String?
        //     }
        // }
        // let body = AuthAppleRequest(
        //     identityToken: identityToken,
        //     email: email,
        //     fullName: AuthAppleRequest.FullName(
        //         givenName: fullName?.givenName,
        //         familyName: fullName?.familyName
        //     )
        // )
        // return try await NetworkManager.shared.request(
        //     .authApple,
        //     body: body,
        //     responseType: AuthResponse.self
        // )

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
