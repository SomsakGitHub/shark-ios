import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var selectedTab = 0
    @State private var showLoginSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                FeedView()
            }

            Tab("Upload", systemImage: "plus.circle.fill", value: 1) {
                UploadView()
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == 1 && !authManager.isAuthenticated {
                showLoginSheet = true
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginPromptSheet()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
}
