import SwiftUI
import AVKit
import AVFoundation



struct InstaItem: View {
    let item: Item
    @StateObject private var loader: MediaLoader
    @State private var aspectRatio: CGFloat = 9/16 // Default aspect ratio
    @State private var showFullScreenImage: Bool = false

    init(item: Item) {
        self.item = item
        _loader = StateObject(wrappedValue: MediaLoader(url: item.thumbnailUrl, isVideo: item.isVideo))
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if loader.isLoading {
                    ProgressView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if item.isVideo {
                    if let player = loader.videoPlayer {
                        VideoPlayerView(player: player)
                            .aspectRatio(aspectRatio, contentMode: .fit)
                            .frame(width: geometry.size.width)
                            .onAppear {
                                // player.play()
                            }
                            .onDisappear {
                                player.pause()
                            }
                            .onTapGesture {
                                if player.timeControlStatus == .paused {
                                    player.play()
                                } else {
                                    player.pause()
                                }
                            }
                    }
                } else {
                    if let image = loader.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width)
                            .onTapGesture {
                                showFullScreenImage = true
                            }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.width / aspectRatio)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onAppear {
                loader.load()
        }
        .onChange(of: loader.image) { newImage in
            if let image = newImage {
                calculateImageAspectRatio(image)
            }
        }
        .onChange(of: loader.videoPlayer) { newPlayer in
            if let player = newPlayer {
                setupPlayerForLooping(player)
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImage) {
            FullScreenImageView(imageUrl: item.mediaUrl, isPresented: $showFullScreenImage)
        }
    }

    private func calculateImageAspectRatio(_ image: UIImage) {
        let size = image.size
        DispatchQueue.main.async {
            self.aspectRatio = size.width / size.height
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

struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        return PlayerView(player: player)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerView: UIView {
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
    InstaItem(item: Item(thumbnailUrl: URL(string:"https://r2.baos.haus/baostagram/7E62B9BB-410B-4CBA-B3EF-64881A2BFEBD/L0/001")!, mediaUrl: URL(string:"https://r2.baos.haus/baostagram/7E62B9BB-410B-4CBA-B3EF-64881A2BFEBD/L0/001")!, creationDate: "2024-09-26T16:39:29-0700", description: "Bao", city: "Los Angeles", state: "CA", isVideo: true))
}
