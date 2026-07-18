import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        Group {
            if authManager.isLoading {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            } else if authManager.isAuthenticated {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AuthManager())
}
