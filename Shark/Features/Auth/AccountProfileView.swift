import SwiftUI

struct AccountProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var selectedTab = 0
    @State private var userVideos: [FeedVideo] = []
    @State private var isLoading = false
    @State private var selectedVideo: FeedVideo?

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    statsSection
                    actionButtonsSection
                    tabBarSection
                    videoGridSection
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
            }
            .task {
                await loadUserVideos()
            }
            .sheet(item: $selectedVideo) { video in
                VideoPlayerScreen(video: video) {}
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)

                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.primary)
            }

            Text(authManager.user?.name ?? "Guest")
                .font(.title3.bold())

            Text("@\(authManager.user?.id.prefix(8).lowercased() ?? "user")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 40) {
            VStack(spacing: 2) {
                Text("\(userVideos.count)")
                    .font(.headline)
                Text("Videos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 2) {
                Text("--")
                    .font(.headline)
                Text("Followers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 2) {
                Text("--")
                    .font(.headline)
                Text("Following")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 16)
    }

    // MARK: - Action Buttons

    private var actionButtonsSection: some View {
        HStack(spacing: 8) {
            Button {} label: {
                Text("Edit profile")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Button {} label: {
                Text("Share profile")
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Button {} label: {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Tab Bar

    private var tabBarSection: some View {
        HStack(spacing: 0) {
            tabButton(icon: "square.grid.2x2", tag: 0)
            tabButton(icon: "bookmark", tag: 1)
            tabButton(icon: "heart", tag: 2)
        }
        .overlay(
            Divider(), alignment: .top
        )
    }

    private func tabButton(icon: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(selectedTab == tag ? .primary : .secondary)

                Rectangle()
                    .fill(selectedTab == tag ? Color.primary : Color.clear)
                    .frame(height: 1.5)
            }
        }
    }

    // MARK: - Video Grid

    @ViewBuilder
    private var videoGridSection: some View {
        if isLoading {
            ProgressView()
                .padding(.top, 40)
        } else if userVideos.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "video.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("No videos yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
        } else {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(userVideos) { video in
                    videoThumbnail(video)
                }
            }
        }
    }

    private func videoThumbnail(_ video: FeedVideo) -> some View {
        GeometryReader { geo in
            ZStack {
                Color(.systemGray6)

                AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "play.fill")
                                .foregroundColor(.secondary)
                        }
                }
                .frame(width: geo.size.width, height: geo.size.width * 1.33)
                .clipped()

                VStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.caption2)
                            .foregroundColor(.white)
                        Text("\(video.likeCount)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 6)
                    .padding(.bottom, 6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: UIScreen.main.bounds.width / 3 * 1.33)
        .onTapGesture {
            selectedVideo = video
        }
    }

    // MARK: - Data

    private func loadUserVideos() async {
        isLoading = true
        do {
            let response = try await FeedService.shared.fetchFeed()
            userVideos = response.videos
        } catch {
            print("Failed to load user videos: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

#Preview {
    AccountProfileView()
        .environment(AuthManager())
}
