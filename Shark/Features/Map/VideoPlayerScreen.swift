import SwiftUI
import AVKit

struct VideoPlayerScreen: View {
    let video: FeedVideo
    var onDismiss: () -> Void

    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                Spacer()
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    HStack {
                        AsyncImage(url: URL(string: video.user.avatarUrl)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Circle().fill(.gray)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(video.user.displayName)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("@\(video.user.username)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("\(video.likeCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if let url = URL(string: video.playbackManifestUrl) {
                player = AVPlayer(url: url)
                player?.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    VideoPlayerScreen(video: FeedVideo(
        id: "1",
        userId: "user1",
        status: "ready",
        originalObjectKey: "",
        playbackManifestUrl: "",
        durationMs: 5000,
        width: 1080,
        height: 1920,
        thumbnailUrl: "",
        createdAt: "",
        updatedAt: "",
        user: FeedUser(id: "1", username: "test", displayName: "Test", avatarUrl: ""),
        likeCount: 100
    )) {}
}
