//
//  Untitled.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/28/24.
//
import Foundation
import SwiftUI
import AVFoundation

class MediaLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var videoPlayer: AVPlayer?
    @Published var isLoading = false
    @Published var aspectRatio: CGFloat = 1.0
    
    private let url: URL
    private let isVideo: Bool
    private static var imageCache = NSCache<NSURL, UIImage>()
    private static var playerCache = NSCache<NSURL, AVPlayer>()

    init(url: URL, isVideo: Bool) {
        self.url = url
        self.isVideo = isVideo
    }

    func load() {
        if isVideo {
            loadVideo()
        } else {
            loadImage()
        }
    }

    private func loadImage() {
        if let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            self.aspectRatio = cachedImage.size.width / cachedImage.size.height
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                Self.imageCache.setObject(image, forKey: self.url as NSURL)
                DispatchQueue.main.async {
                    self.image = image
                    self.aspectRatio = image.size.width / image.size.height
                    self.isLoading = false
                }
            }
        }.resume()
    }

    private func loadVideo() {
        if let cachedPlayer = Self.playerCache.object(forKey: url as NSURL) {
            print("Cached Video")
            self.videoPlayer = cachedPlayer
            self.loadVideoProperties(player: cachedPlayer)
            return
        }
        
        isLoading = true
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        Self.playerCache.setObject(player, forKey: url as NSURL)
        
        DispatchQueue.main.async {
            self.videoPlayer = player
            self.isLoading = false
            self.loadVideoProperties(player: player)
        }
    }
    
    private func loadVideoProperties(player: AVPlayer) {
        guard let playerItem = player.currentItem else { return }
        
        let assetKeysToLoad = ["tracks", "duration"]
        playerItem.asset.loadValuesAsynchronously(forKeys: assetKeysToLoad) {
            DispatchQueue.main.async {
                guard playerItem.asset.statusOfValue(forKey: "tracks", error: nil) == .loaded,
                      playerItem.asset.statusOfValue(forKey: "duration", error: nil) == .loaded else {
                    self.isLoading = false
                    return
                }
                
                if let track = playerItem.asset.tracks(withMediaType: .video).first {
                    // Use a default aspect ratio if the natural size is not immediately available
                    let naturalSize = track.naturalSize
                    if naturalSize.width > 0 && naturalSize.height > 0 {
                        let size = naturalSize.applying(track.preferredTransform)
                        self.aspectRatio = abs(size.width / size.height)
                    } else {
                        print("Natural size not immediately available, using default aspect ratio")
                        self.aspectRatio = 16/9 // Default to 16:9 aspect ratio
                    }
                }
                
                self.isLoading = false
            }
        }
    }
}
