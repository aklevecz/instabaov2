//import SwiftUI
//import AVKit
//import AVFoundation
//
//struct InstaItem2: View {
//    let width: Double
//    let height: Double
//    let item: Item
//    @StateObject private var loader: MediaLoader
//    @State private var videoAspectRatio: CGFloat?
//
//    init(width: Double, height: Double, item: Item) {
//        self.width = width
//        self.height = height
//        self.item = item
//        _loader = StateObject(wrappedValue: MediaLoader(url: item.thumbnailUrl, isVideo: item.isVideo))
//    }
//
//    var body: some View {
//        VStack {
//            if item.isVideo {
//                if let player = loader.videoPlayer {
//                    VideoPlayer(player: player)
//                        .aspectRatio(videoAspectRatio, contentMode: .fit)
//                        .frame(width: width, height:500)
//                        .onAppear {
//                            Task {
//                                print(width)
//                            }
//                            calculateVideoAspectRatio(for: player)
//                        }
//                } else {
//                    ProgressView()
////                        .frame(width: width, height: width * 16/9) // Default aspect ratio
//                }
//            } else {
//                if let image = loader.image {
//                    Image(uiImage: image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: width)
//                } else {
//                    ProgressView()
////                        .frame(width: width, height: width * 16/9) // Default aspect ratio
//                }
//            }
//        }
//        .onAppear(perform: loader.load)
//    }
//
//    private func calculateVideoAspectRatio(for player: AVPlayer) {
//        guard let item = player.currentItem else { return }
//        
//        let tracks = item.asset.tracks(withMediaType: .video)
//        if let videoTrack = tracks.first {
//            let size = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
//            DispatchQueue.main.async {
//                print("Video aspect ratio: \(abs(size.width / size.height))")
//                self.videoAspectRatio = abs(size.width / size.height)
//            }
//        }
//    }
//}
