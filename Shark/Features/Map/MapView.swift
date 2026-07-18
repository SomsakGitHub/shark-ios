import SwiftUI
import MapKit

struct MapView: View {
    @Environment(LocationManager.self) private var locationManager
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    ))
    @State private var videos: [FeedVideo] = []
    @State private var videoCoordinates: [String: CLLocationCoordinate2D] = [:]
    @State private var selectedVideo: FeedVideo?

    private let mockCenter = CLLocationCoordinate2D(latitude: 13.630309274545938, longitude: 100.65888190825626)

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                UserAnnotation()

                ForEach(videos) { video in
                    if let coordinate = videoCoordinates[video.id] {
                        Annotation(video.user.displayName, coordinate: coordinate) {
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
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

        }
        .fullScreenCover(item: $selectedVideo) { video in
            VideoPlayerScreen(video: video) {
                selectedVideo = nil
            }
        }
        .task {
            await loadVideos()
            if let location = locationManager.location {
                centerOnUserLocation()
            }
        }
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if newStatus == .authorizedWhenInUse || newStatus == .authorized {
                locationManager.startUpdating()
            }
        }
        .onChange(of: locationManager.location) { _, _ in
            centerOnUserLocation()
        }
    }

    private func centerOnUserLocation() {
        guard let location = locationManager.location else { return }
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }

    private func loadVideos() async {
        do {
            let response = try await FeedService.shared.fetchFeed()
            videos = Array(response.videos.prefix(10))
            generateMockCoordinates()
        } catch {
            print("Failed to load videos for map: \(error)")
        }
    }

    private func generateMockCoordinates() {
        for (index, video) in videos.enumerated() {
            let angle = (Double(index) / Double(videos.count)) * 2 * .pi
            let radius = Double.random(in: 0.005...0.02)
            let lat = mockCenter.latitude + radius * cos(angle)
            let lon = mockCenter.longitude + radius * sin(angle)
            videoCoordinates[video.id] = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
    }
}

#Preview {
    MapView()
        .environment(LocationManager())
}
