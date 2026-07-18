import SwiftUI

struct FeedView: View {
    @State private var videos: [FeedVideo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedIndex = 0
    @State private var selectedUser: FeedUser?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else if let errorMessage = errorMessage {
                VStack {
                    Text(errorMessage)
                        .foregroundColor(.white)
                    Button("Retry") {
                        Task {
                            await loadFeed()
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                }
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(videos.enumerated()), id: \.element.id) { index, video in
                        VideoCardView(video: video) {
                            selectedUser = video.user
                        }
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
        }
        .task {
            await loadFeed()
        }
        .sheet(item: $selectedUser) { user in
            ProfileView(user: user)
        }
    }
    
    private func loadFeed() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await FeedService.shared.fetchFeed()
            videos = response.videos
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct VideoCardView: View {
    let video: FeedVideo
    var onUserTap: (() -> Void)?
    @State private var isPlaying = true
    @State private var showLikeAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VideoPlayerView(videoURL: video.playbackManifestUrl, isPlaying: isPlaying)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
                
                VStack {
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                onUserTap?()
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: video.user.avatarUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())

                                    Text("@\(video.user.username)")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }

                            Text(video.user.displayName)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Duration: \(video.durationMs / 1000)s")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Button(action: {
                                showLikeAnimation = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showLikeAnimation = false
                                }
                            }) {
                                VStack {
                                    Image(systemName: "heart.fill")
                                        .font(.title)
                                        .foregroundColor(showLikeAnimation ? .red : .white)
                                    
                                    Text("\(video.likeCount)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "bubble.right.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                    
                                    Text("0")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "arrowshape.turn.up.right.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                    
                                    Text("Share")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .onTapGesture {
            isPlaying.toggle()
        }
    }
}

#Preview {
    FeedView()
}
