import SwiftUI
import PhotosUI
import AVKit

struct UploadView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var caption = ""
    @State private var isUploading = false
    @State private var showCamera = false
    @State private var player: AVPlayer?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let videoURL = videoURL, let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 500)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onAppear {
                                player.seek(to: .zero)
                            }
                    } else {
                        uploadPlaceholder
                    }

                    if videoURL != nil {
                        captionField
                        uploadButton
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Upload")
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(isPresented: .constant(false), selection: $selectedItem, matching: .videos)
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let tempURL = saveTempVideo(data: data) {
                        videoURL = tempURL
                        player = AVPlayer(url: tempURL)
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(videoURL: $videoURL, player: $player)
            }
            .alert("Upload Complete!", isPresented: $showSuccess) {
                Button("OK") {
                    resetForm()
                }
            } message: {
                Text("Your video has been uploaded successfully.")
            }
        }
    }

    private var uploadPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "video.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Select or record a video")
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 20) {
                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                PhotosPicker("Gallery", selection: $selectedItem, matching: .videos)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var captionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption")
                .font(.headline)
            TextField("Write a caption...", text: $caption, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var uploadButton: some View {
        Button {
            uploadVideo()
        } label: {
            if isUploading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            } else {
                Text("Upload")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(caption.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .disabled(caption.isEmpty || isUploading)
    }

    private func uploadVideo() {
        isUploading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isUploading = false
            showSuccess = true
        }
    }

    private func resetForm() {
        selectedItem = nil
        videoURL = nil
        caption = ""
        player = nil
    }

    private func saveTempVideo(data: Data) -> URL? {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
        try? data.write(to: tempURL)
        return tempURL
    }
}

#Preview {
    UploadView()
}
