import SwiftUI

struct ProfileView: View {
    let user: FeedUser
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    AsyncImage(url: URL(string: user.avatarUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)

                    VStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.title2.bold())

                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("--")
                                .font(.title3.bold())
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        VStack(spacing: 4) {
                            Text("--")
                                .font(.title3.bold())
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        VStack(spacing: 4) {
                            Text("--")
                                .font(.title3.bold())
                            Text("Likes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    Button {
                    } label: {
                        Text("Follow")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(user: FeedUser(
        id: "1",
        username: "joker.arthorn",
        displayName: "Arthorn Kittinukul",
        avatarUrl: ""
    ))
}
