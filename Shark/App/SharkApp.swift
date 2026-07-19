import SwiftUI
import FirebaseCore

@main
struct SharkApp: App {
    @State private var authManager: AuthManager
    @State private var locationManager = LocationManager()

    init() {
        FirebaseConfig.configure()
        _authManager = State(initialValue: AuthManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environment(locationManager)
                .task {
                    locationManager.requestPermission()
                }
        }
    }
}
