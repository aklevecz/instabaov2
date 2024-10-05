//
//  ImageDataCache.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 10/2/24.
//
import SwiftUI

class ImageDataCache {
    static let shared = ImageDataCache()
    private let cache = NSCache<NSString, NSData>()
    
    private init() {}
    
    func setImageData(_ data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func getImageData(forKey key: String) -> Data? {
        return cache.object(forKey: key as NSString) as Data?
    }
    
    func fetchImage(named name: String, completion: @escaping (Data?) -> Void) {
        if let cachedImageData = getImageData(forKey: name) {
            print("Using cached image data for: \(name)")
            completion(cachedImageData)
            return
        }

        let urlString = "https://r2.baos.haus/bao2/\(name).png"
        print(urlString)
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching image \(name): \(error)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response for URL: \(urlString)")
                completion(nil)
                return
            }

            if let imageData = data {
                self?.setImageData(imageData, forKey: name)
                print("Successfully fetched and cached image data for: \(name)")
                completion(imageData)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
