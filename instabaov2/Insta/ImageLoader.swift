//
//  ImageLoader.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//

import Foundation
import SwiftUI

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let url: URL
    private static let cache = NSCache<NSURL, UIImage>()

    init(url: URL) {
        self.url = url
    }

    func load() {
        if let cachedImage = ImageLoader.cache.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                ImageLoader.cache.setObject(downloadedImage, forKey: self.url as NSURL)
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
