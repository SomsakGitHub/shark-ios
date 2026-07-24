import SwiftUI

struct ContentView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(LocationManager.self) private var locationManager
    @State private var selectedTab = 0
    @State private var showLoginSheet = false
    @State private var pendingTab: Int?

    var body: some View {
        ZStack(alignment: .top) {
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

                Tab("Profile", systemImage: "person.fill", value: 3) {
                    AccountProfileView()
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

            if locationManager.needsPermission {
                locationBanner
            }
        }
    }

    private var locationBanner: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)

                Text("Enable location to see videos near you")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Button {
                    locationManager.requestPermission()
                } label: {
                    Text("Enable")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }

                Button {
                    locationManager.dismissBanner()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}

#Preview {
    ContentView()
        .environment(AuthManager())
        .environment(LocationManager())
}
