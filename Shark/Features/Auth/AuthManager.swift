import Foundation
import AuthenticationServices

@Observable
@MainActor
final class AuthManager {
    var isAuthenticated = false
    var user: AuthUser?
    var isLoading = true

    private let tokenKey = "auth_token"
    private let userIdKey = "apple_user_id"
    private let userEmailKey = "user_email"
    private let userNameKey = "user_name"

    init() {
        restoreSession()
    }

    func restoreSession() {
        guard let userId = KeychainService.read(key: userIdKey) else {
            isLoading = false
            return
        }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userId) { [weak self] state, _ in
            Task { @MainActor in
                switch state {
                case .authorized:
                    self?.user = AuthUser(
                        id: userId,
                        email: KeychainService.read(key: self?.userEmailKey ?? ""),
                        name: KeychainService.read(key: self?.userNameKey ?? "")
                    )
                    self?.isAuthenticated = true
                case .revoked, .notFound:
                    self?.signOut()
                default:
                    break
                }
                self?.isLoading = false
            }
        }
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async -> Bool {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return false }
            guard let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else { return false }

            do {
                let authResponse = try await AuthService.authenticate(
                    identityToken: identityToken,
                    email: credential.email,
                    fullName: credential.fullName
                )

                KeychainService.save(key: tokenKey, value: authResponse.token)
                KeychainService.save(key: userIdKey, value: credential.user)
                if let email = credential.email {
                    KeychainService.save(key: userEmailKey, value: email)
                }
                if let name = credential.fullName {
                    let fullName = "\(name.givenName ?? "") \(name.familyName ?? "")".trimmingCharacters(in: .whitespaces)
                    if !fullName.isEmpty {
                        KeychainService.save(key: userNameKey, value: fullName)
                    }
                }

                user = AuthUser(
                    id: credential.user,
                    email: authResponse.email ?? KeychainService.read(key: userEmailKey),
                    name: authResponse.name ?? KeychainService.read(key: userNameKey)
                )
                isAuthenticated = true
                return true
            } catch {
                print("Auth failed: \(error)")
                return false
            }

        case .failure(let error):
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                return false
            }
            print("Apple Sign In error: \(error)")
            return false
        }
    }

    func mockSignIn() {
        let mockUserId = "mock_user_\(UUID().uuidString)"
        let mockToken = "mock_jwt_token_\(UUID().uuidString)"

        KeychainService.save(key: tokenKey, value: mockToken)
        KeychainService.save(key: userIdKey, value: mockUserId)
        KeychainService.save(key: userEmailKey, value: "demo@shark.app")
        KeychainService.save(key: userNameKey, value: "Demo User")

        user = AuthUser(id: mockUserId, email: "demo@shark.app", name: "Demo User")
        isAuthenticated = true
    }

    func signOut() {
        KeychainService.delete(key: tokenKey)
        KeychainService.delete(key: userIdKey)
        KeychainService.delete(key: userEmailKey)
        KeychainService.delete(key: userNameKey)
        user = nil
        isAuthenticated = false
    }

    func getAuthToken() -> String? {
        KeychainService.read(key: tokenKey)
    }
}
