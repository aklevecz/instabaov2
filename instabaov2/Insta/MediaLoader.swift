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
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                Self.imageCache.setObject(image, forKey: self.url as NSURL)
                DispatchQueue.main.async {
                    self.image = image
                    self.isLoading = false
                }
            }
        }.resume()
    }

    private func loadVideo() {
        if let cachedPlayer = Self.playerCache.object(forKey: url as NSURL) {
            self.videoPlayer = cachedPlayer
            return
        }
        
        isLoading = true
        let player = AVPlayer(url: url)
        Self.playerCache.setObject(player, forKey: url as NSURL)
        DispatchQueue.main.async {
            self.videoPlayer = player
            self.isLoading = false
        }
    }
}
