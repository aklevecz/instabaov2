import SwiftUI
import AVKit
import AVFoundation

struct InstaItem: View {
    let item: Item
    @StateObject private var loader: MediaLoader
    @State private var aspectRatio: CGFloat = 1 // Default square aspect ratio
    @State private var showFullScreenImage: Bool = false
    @State private var isLoaded: Bool = false

    init(item: Item) {
        self.item = item
        _loader = StateObject(wrappedValue: MediaLoader(url: item.thumbnailUrl, isVideo: item.isVideo))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.0))
                    .aspectRatio(1, contentMode: .fit)
                Group {
                    if loader.isLoading {
                        ProgressView()
                    } else if item.isVideo {
                        VideoPlayerView(loader: loader)
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    } else {
                        if let image = loader.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    showFullScreenImage = true
                                }
                        }
                    }
                }
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onAppear {
            loader.load()
        }
        .onChange(of: loader.aspectRatio) { newAspectRatio in
            self.aspectRatio = newAspectRatio
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageUrl: item.mediaUrl, isPresented: $showFullScreenImage)
        }
    }
}

struct VideoPlayerView: View {
    @ObservedObject var loader: MediaLoader
    @State private var isPlaying: Bool = false

    var body: some View {
        ZStack {
            if let player = loader.videoPlayer {
                PlayerView(player: player)
                    .onAppear {
                        setupPlayerForLooping(player)
                    }
                    .onDisappear {
                        player.pause()
                    }
                
                if !isPlaying {
                    Button(action: {
                        player.play()
                        isPlaying = true
                    }) {
                        Image(systemName: "play.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onTapGesture {
            if let player = loader.videoPlayer {
                if player.timeControlStatus == .paused {
                    player.play()
                    isPlaying = true
                } else {
                    player.pause()
                    isPlaying = false
                }
            }
        }
    }

    private func setupPlayerForLooping(_ player: AVPlayer) {
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem, queue: .main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
}

struct PlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(player: player)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

#Preview {
//    InstaItem(item: Item(thumbnailUrl: URL(string:"https://r2.baos.haus/baostagram/7E62B9BB-410B-4CBA-B3EF-64881A2BFEBD/L0/001")!, mediaUrl: URL(string:"https://r2.baos.haus/baostagram/7E62B9BB-410B-4CBA-B3EF-64881A2BFEBD/L0/001")!, creationDate: "2024-09-26T16:39:29-0700", description: "Bao", city: "Los Angeles", state: "CA", isVideo: true))
    
    InstaItem(item: Item(thumbnailUrl: URL(string:"https://r2.baos.haus/baostagram/0238100A-A6BB-4224-8FF9-C44FD9678C74/L0/001")!, mediaUrl: URL(string:"https://r2.baos.haus/baostagram/0238100A-A6BB-4224-8FF9-C44FD9678C74/L0/001")!, creationDate: "2024-09-26T16:39:29-0700", description: "Bao", city: "Los Angeles", state: "CA", isVideo: false))
}
