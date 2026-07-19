import Foundation
import AuthenticationServices
import FirebaseAuth

@Observable
@MainActor
final class AuthManager {
    var isAuthenticated = false
    var user: AuthUser?
    var isLoading = true

    nonisolated(unsafe) private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?

    init() {
        startListeningAuthState()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func startListeningAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let firebaseUser {
                    self.user = AuthUser(
                        id: firebaseUser.uid,
                        email: firebaseUser.email,
                        name: firebaseUser.displayName
                    )
                    self.isAuthenticated = true
                    print("👤 Auth state: Signed in as \(firebaseUser.uid)")
                } else {
                    self.user = nil
                    self.isAuthenticated = false
                    print("👤 Auth state: Signed out")
                }
                self.isLoading = false
            }
        }
    }

    func handleAppleSignIn(result: Result<ASAuthorization, Error>) async -> Bool {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return false
            }
            guard let identityTokenData = credential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                return false
            }
            guard let nonce = currentNonce else {
                print("Firebase Auth Error: nonce is missing")
                return false
            }

            let firebaseCredential = OAuthProvider.credential(
                providerID: AuthProviderID.apple,
                idToken: identityToken,
                rawNonce: nonce
            )

            do {
                let authResult = try await Auth.auth().signIn(with: firebaseCredential)

                if let fullName = credential.fullName {
                    let displayName = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")"
                        .trimmingCharacters(in: .whitespaces)
                    if !displayName.isEmpty {
                        let changeRequest = authResult.user.createProfileChangeRequest()
                        changeRequest.displayName = displayName
                        try await changeRequest.commitChanges()
                    }
                }

                let idToken = try await authResult.user.getIDToken()
                print("✅ Firebase Sign In succeeded")
                print("   UID: \(authResult.user.uid)")
                print("   Email: \(authResult.user.email ?? "N/A")")
                print("   Display Name: \(authResult.user.displayName ?? "N/A")")
                print("   Firebase ID Token: \(idToken)")

                return true
            } catch {
                print("❌ Firebase Auth failed: \(error.localizedDescription)")
                return false
            }

        case .failure(let error):
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                return false
            }
            print("Apple Sign In error: \(error.localizedDescription)")
            return false
        }
    }

    func setNonce(_ nonce: String) {
        currentNonce = nonce
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            print("👋 Signed out successfully")
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }

    func getIDToken() async -> String? {
        guard let user = Auth.auth().currentUser else { return nil }
        do {
            return try await user.getIDToken()
        } catch {
            print("Failed to get ID token: \(error.localizedDescription)")
            return nil
        }
    }
}
