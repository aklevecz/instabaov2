//
//  InstaItem.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//

import SwiftUI

struct InstaItem: View {
    let width: Double
    let height: Double
    let item: Item
    @StateObject private var loader: ImageLoader

    init(width: Double, height: Double, item: Item) {
        self.width = width
        self.height = height
        self.item = item
        _loader = StateObject(wrappedValue: ImageLoader(url: item.thumbnailUrl))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width, alignment: .center)
            } else {
                ProgressView()
                    .frame(width: width, height: height)
            }
        }
        .onAppear(perform: loader.load)
    }
}
