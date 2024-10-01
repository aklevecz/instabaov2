//
//  InstaModel.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//

/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation
import AVFoundation

struct Item: Identifiable {
    let id = UUID()
    let thumbnailUrl: URL
    let mediaUrl: URL
    let creationDate: String
    let description: String
    let city: String
    let state: String
    let isVideo: Bool
}

extension Item: Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

class InstaModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

    let baostagramListUrl = "https://los.baos.haus/instabao/images"
    let r2StorageEndpoint: String = "https://r2.baos.haus"

    struct ItemData: Codable {
        let key: String
        let description: String?
        let city: String?
        let state: String?
        let creationDate: String?
        let isVideo: Bool?
        let contentType: String?
    }

    @MainActor
    func fetchItems() async {
        isLoading = true
        error = nil

        do {
            guard let url = URL(string: baostagramListUrl) else {
                throw URLError(.badURL)
            }

            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let itemsData = try JSONDecoder().decode([ItemData].self, from: data)
            items = itemsData.compactMap { itemData in
                let isVideo = itemData.contentType == "video/mp4" ? true : false
                
                guard let thumbnailUrl = isVideo ? URL(string: buildVideoUrl(key: itemData.key)) : URL(string: buildImageUrl(key: itemData.key, height: 700)),
                      let mediaUrl = isVideo ? URL(string: buildVideoUrl(key: itemData.key)) : URL(string: buildImageUrl(key: itemData.key)) else {
                    return nil
                }
                

                
                let item = Item(
                    thumbnailUrl: thumbnailUrl,
                    mediaUrl: mediaUrl,
                    creationDate: itemData.creationDate ?? "2024",
                    description: itemData.description ?? "Default description",
                    city: itemData.city ?? "Los Angeles",
                    state: itemData.state ?? "CA",
                    isVideo: isVideo
                )
                
                return item
            }
//            print(items)
        } catch {
            self.error = error
            print("Error: \(error)")
        }

        isLoading = false
    }

    private func buildImageUrl(key: String, height: Int? = nil) -> String {
        var url = "https://baos.haus/cdn-cgi/image/width=auto,quality=100,fit=contain"
        if let height = height {
            url += ",height=\(height)"
        } else {
            url += ",height=auto"
        }
        return "\(url)/\(r2StorageEndpoint)/\(key)"
    }

    private func buildVideoUrl(key: String) -> String {
        return "\(r2StorageEndpoint)/\(key)"
    }
}
