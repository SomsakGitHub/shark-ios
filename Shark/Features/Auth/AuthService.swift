import Foundation
import FirebaseAuth

struct AuthService {
    static func getCurrentUser() -> AuthUser? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return AuthUser(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            name: firebaseUser.displayName
        )
    }

    static func isSignedIn() -> Bool {
        Auth.auth().currentUser != nil
    }
}
