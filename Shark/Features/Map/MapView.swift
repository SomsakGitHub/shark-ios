import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationManager.self) private var locationManager
    @State private var position: MapCameraPosition = .automatic
    @State private var videos: [FeedVideo] = []
    @State private var selectedVideo: FeedVideo?

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                UserAnnotation()

                ForEach(videos) { video in
                    Annotation(video.user.displayName, coordinate: randomCoordinate(for: video)) {
                        VStack(spacing: 0) {
                            AsyncImage(url: URL(string: video.user.avatarUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Circle()
                                    .fill(.gray)
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .shadow(radius: 3)

                            Image(systemName: "triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .rotationEffect(.degrees(180))
                                .offset(y: -3)
                        }
                        .onTapGesture {
                            selectedVideo = video
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

            if selectedVideo != nil {
                VStack {
                    Spacer()
                    videoPreview
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: selectedVideo != nil)
            }
        }
        .task {
            await loadVideos()
        }
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if newStatus == .authorizedWhenInUse || newStatus == .authorized {
                centerOnUserLocation()
            }
        }
        .onChange(of: locationManager.location) { _, newLocation in
            if newLocation != nil {
                centerOnUserLocation()
            }
        }
    }

    private var videoPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: selectedVideo!.user.avatarUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(.gray)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(selectedVideo!.user.displayName)
                        .font(.headline)
                    Text("@\(selectedVideo!.user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    selectedVideo = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Label("\(selectedVideo!.likeCount) likes", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                Spacer()
                Label("\(selectedVideo!.durationMs / 1000)s", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private func centerOnUserLocation() {
        guard let location = locationManager.location else { return }
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
    }

    private func loadVideos() async {
        do {
            let response = try await FeedService.shared.fetchFeed()
            videos = response.videos
        } catch {
            print("Failed to load videos for map: \(error)")
        }
    }

    private func randomCoordinate(for video: FeedVideo) -> CLLocationCoordinate2D {
        let hash = abs(video.id.hashValue)
        let lat = Double(hash % 1800 - 900) / 10.0
        let lon = Double((hash / 1800) % 3600 - 1800) / 10.0
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

#Preview {
    MapView()
        .environment(LocationManager())
}
