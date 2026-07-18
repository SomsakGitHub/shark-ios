import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                FeedView()
            }
            Tab("Upload", systemImage: "plus.circle.fill") {
                UploadView()
            }
        }
    }
}

#Preview {
    ContentView()
}
