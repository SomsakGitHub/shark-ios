import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    let videoURL: String
    let isPlaying: Bool
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        let view = VideoPlayerUIView()
        view.setupPlayer(url: videoURL)
        return view
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        if isPlaying {
            uiView.play()
        } else {
            uiView.pause()
        }
    }
}

class VideoPlayerUIView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var loopObserver: Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayer(url: String) {
        guard let videoURL = URL(string: url) else { return }
        
        player = AVPlayer(url: videoURL)
        player?.isMuted = true
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = bounds
        
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
    
    func play() {
        player?.play()
    }
    
 func pause() {
        player?.pause()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    deinit {
        if let observer = loopObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
