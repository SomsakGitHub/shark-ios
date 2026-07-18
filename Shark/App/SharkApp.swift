import SwiftUI

@main
struct SharkApp: App {
    @State private var authManager = AuthManager()
    @State private var locationManager = LocationManager()

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
