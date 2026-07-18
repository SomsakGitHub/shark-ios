import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var selectedTab = 0
    @State private var showLoginSheet = false
    @State private var pendingTab: Int?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                FeedView()
            }

            Tab("Map", systemImage: "map.fill", value: 1) {
                MapView()
            }

            Tab("Upload", systemImage: "plus.circle.fill", value: 2) {
                UploadView()
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            guard !authManager.isAuthenticated else { return }
            if newValue == 1 || newValue == 2 {
                pendingTab = newValue
                showLoginSheet = true
                selectedTab = 0
            }
        }
        .sheet(isPresented: $showLoginSheet) {
            LoginPromptSheet {
                guard let tab = pendingTab else { return }
                selectedTab = tab
                pendingTab = nil
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
}
