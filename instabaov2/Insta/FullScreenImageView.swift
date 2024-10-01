//
//  FullScreenImageView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/29/24.
//
import SwiftUI

struct FullScreenImageView: View {
    let imageUrl: URL
    @Binding var isPresented: Bool
    @State private var image: UIImage? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    @State private var isLoading: Bool = true
    @State private var dragOffset: CGSize = .zero
    @State private var backgroundColor: Color = .black

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale *= delta
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 {
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    } else {
                                        dragOffset = value.translation
                                        updateBackgroundOpacity(value.translation)
                                    }
                                }
                                .onEnded { value in
                                    if scale > 1 {
                                        lastOffset = offset
                                    } else {
                                        let translation = value.translation
                                        if shouldDismiss(translation: translation) {
                                            isPresented = false
                                        } else {
                                            withAnimation(.spring()) {
                                                dragOffset = .zero
                                                backgroundColor = .black
                                            }
                                        }
                                    }
                                }
                        )
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation {
                                        if scale > 1 {
                                            scale = 1
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            scale = 2
                                        }
                                    }
                                }
                        )
                }
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        isLoading = true
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            if let data = data, let loadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = loadedImage
                    self.isLoading = false
                }
            } else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                self.isLoading = false
            }
        }.resume()
    }
    
    private func updateBackgroundOpacity(_ translation: CGSize) {
        let progress = max(abs(translation.height), abs(translation.width)) / 300
        let opacity = 1 - min(progress, 1)
        backgroundColor = Color.black.opacity(Double(opacity))
    }
    
    private func shouldDismiss(translation: CGSize) -> Bool {
        let dismissalThreshold: CGFloat = 100
        return abs(translation.width) > dismissalThreshold || abs(translation.height) > dismissalThreshold
    }
}

// Preview remains the same
