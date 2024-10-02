//////
//////  ARModel.swift
//////  instabaov2
//////
//////  Created by Ariel Klevecz on 9/25/24.
//////
//import SwiftUI
//import ARKit
//import RealityKit
//import AVKit
//import Combine
//
//struct VideoInfo {
//    let url: URL
//    var player: AVPlayer?
//    var status: VideoStatus = .notLoaded
//}
//
//enum VideoStatus {
//    case notLoaded
//    case loading
//    case ready
//    case failed
//}
//
//struct ARViewWrapper: UIViewRepresentable {
//    let arView: ARView
//
//    func makeUIView(context: Context) -> ARView {
//        arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {}
//}
//
//class ARModel:NSObject, ObservableObject, ARSessionDelegate {
//    @ObservedObject private var authModel = AuthModel.shared
//    var arView = ARView(frame: .zero)
//    var contentEntity = AnchorEntity()
//    private var cancellables: Set<AnyCancellable> = []
//    private var model: ModelEntity?
//    @Published var referenceImages: Set<ARReferenceImage> = []
//    @Published var videos: [String: VideoInfo] = [:]
//    
//    private var imageDataCache: ImageDataCache {
//            return ImageDataCache.shared
//        }
//    
//    func setup(config: GameConfig) {
//            arView.scene.addAnchor(contentEntity)
//            arView.session.delegate = self
//
//            // let names = ["baodj", "baomotto"]
//            let names = config.imageTargetNames
//            let dispatchGroup = DispatchGroup()
//
//            fetchReferenceImages(imageNames: names, dispatchGroup: dispatchGroup)
//            fetchVideos(videoNames: names, dispatchGroup: dispatchGroup)
//
//            // Start AR session after all images and videos are loaded
//            dispatchGroup.notify(queue: .main) {
//                self.startARSession()
//            }
//        }
//
//        private func fetchReferenceImages(imageNames: [String], dispatchGroup: DispatchGroup) {
//            for name in imageNames {
//                dispatchGroup.enter()
//                ImageDataCache.shared.fetchImage(named: name) { [weak self] imageData in
//                    defer { dispatchGroup.leave() }
//                    
//                    guard let self = self, let imageData = imageData else {
//                        print("Failed to fetch image data for: \(name)")
//                        return
//                    }
//                    
//                    self.createReferenceImage(from: imageData, named: name) { referenceImage in
//                        if let referenceImage = referenceImage {
//                            DispatchQueue.main.async {
//                                self.referenceImages.insert(referenceImage)
//                            }
//                            print("Added reference image for: \(name)")
//                        } else {
//                            print("Failed to create reference image for: \(name)")
//                        }
//                    }
//                }
//            }
//        }
//
//        private func fetchVideos(videoNames: [String], dispatchGroup: DispatchGroup) {
//            for name in videoNames {
//                dispatchGroup.enter()
//                let urlString = "https://r2.baos.haus/bao2/\(name).mp4"
//                guard let url = URL(string: urlString) else {
//                    print("Invalid video URL: \(urlString)")
//                    dispatchGroup.leave()
//                    continue
//                }
//
//                videos[name] = VideoInfo(url: url)
//                loadVideoAsset(for: name, dispatchGroup: dispatchGroup)
//            }
//        }
//
//        private func loadVideoAsset(for name: String, dispatchGroup: DispatchGroup) {
//            guard var videoInfo = videos[name] else {
//                dispatchGroup.leave()
//                return
//            }
//
//            videoInfo.status = .loading
//            videos[name] = videoInfo
//
//            let asset = AVURLAsset(url: videoInfo.url)
//            let requiredAssetKeys = ["playable", "tracks", "duration"]
//
//            asset.loadValuesAsynchronously(forKeys: requiredAssetKeys) { [weak self] in
//                defer { dispatchGroup.leave() } // Ensure dispatchGroup.leave() is called regardless of outcome
//
//                var error: NSError? = nil
//                for key in requiredAssetKeys {
//                    let status = asset.statusOfValue(forKey: key, error: &error)
//                    if status == .failed {
//                        DispatchQueue.main.async {
//                            videoInfo.status = .failed
//                            self?.videos[name] = videoInfo
//                            print("Failed to load video asset key \(key) for: \(name)")
//                        }
//                        return
//                    }
//                }
//
//                // Now load naturalSize and preferredTransform for the first video track
//                guard let videoTrack = asset.tracks(withMediaType: .video).first else {
//                    DispatchQueue.main.async {
//                        videoInfo.status = .failed
//                        self?.videos[name] = videoInfo
//                        print("No video tracks found for: \(name)")
//                    }
//                    return
//                }
//
//                let requiredTrackKeys = ["naturalSize", "preferredTransform"]
//                videoTrack.loadValuesAsynchronously(forKeys: requiredTrackKeys) {
//                    var error: NSError? = nil
//                    for key in requiredTrackKeys {
//                        let status = videoTrack.statusOfValue(forKey: key, error: &error)
//                        if status == .failed {
//                            DispatchQueue.main.async {
//                                videoInfo.status = .failed
//                                self?.videos[name] = videoInfo
//                                print("Failed to load video track key \(key) for: \(name)")
//                            }
//                            return
//                        }
//                    }
//
//                    // All required properties are loaded; proceed to create the player
//                    DispatchQueue.main.async {
//                        let playerItem = AVPlayerItem(asset: asset)
//                        let player = AVPlayer(playerItem: playerItem)
//                        videoInfo.player = player
//                        videoInfo.status = .ready
//                        self?.videos[name] = videoInfo
//                        print("Video loaded successfully for: \(name)")
//                    }
//                }
//            }
//        }
//
//    
//    private func createReferenceImage(from imageData: Data, named imageName: String, completion: @escaping (ARReferenceImage?) -> Void) {
//        guard let uiImage = UIImage(data: imageData) else {
//            print("Failed to create UIImage from data for: \(imageName)")
//            completion(nil)
//            return
//        }
//        
//        guard let cgImage = uiImage.cgImage else {
//            print("Failed to get CGImage from UIImage for: \(imageName)")
//            completion(nil)
//            return
//        }
//        
//        // You may want to adjust the physical width based on your use case
//        let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1)
//        referenceImage.name = imageName
//        completion(referenceImage)
//    }
//    
//    private func startARSession() {
//        let configuration = ARImageTrackingConfiguration()
//        configuration.trackingImages = self.referenceImages
//        configuration.maximumNumberOfTrackedImages = 5
//        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
//    }
//    
//    func startSession(with configuration: ARConfiguration) {
//        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
//    }
//    
//    func stopSession() {
//        arView.session.pause()
//    }
//    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//            guard let imageAnchor = anchors.first as? ARImageAnchor else { return }
//            guard let imageName = imageAnchor.referenceImage.name else { return }
//            print("Image anchor: \(imageName)")
//            
//            guard let videoInfo = videos[imageName] else { return }
//            switch videoInfo.status {
//            case .ready:
//                displayVideo(videoInfo: videoInfo, for: imageAnchor)
//            case .notLoaded, .loading:
//                print("NO LOADED")
//                // If the video isn't ready yet, we can start loading it now
////                loadVideoAsset(for: imageName)
//            case .failed:
//                print("Failed to load video for: \(imageName)")
//            }
//            
//            var currentSecrets = Set(authModel.collectedSecrets)
//            currentSecrets.insert(imageName)
//            authModel.updateCollectedSecrets(Array(currentSecrets))
//    }
//
//    private func displayVideo(videoInfo: VideoInfo, for imageAnchor: ARImageAnchor) {
//        guard let player = videoInfo.player else { return }
//
//        DispatchQueue.main.async {
//            player.seek(to: .zero)
//            player.play()
//
//            let videoMaterial = VideoMaterial(avPlayer: player)
//            let referenceImage = imageAnchor.referenceImage
//            let imageSize = referenceImage.physicalSize
//            let anchorEntity = AnchorEntity(anchor: imageAnchor)
//
//            let entity = ModelEntity(
//                mesh: .generatePlane(
//                    width: Float(imageSize.width),
//                    depth: Float(imageSize.height)
//                ),
//                materials: [videoMaterial]
//            )
//            anchorEntity.addChild(entity)
//            self.contentEntity.addChild(anchorEntity)
//
//            // Set up looping
//            NotificationCenter.default.addObserver(
//                forName: .AVPlayerItemDidPlayToEndTime,
//                object: player.currentItem,
//                queue: .main
//            ) { _ in
//                player.seek(to: .zero)
//                player.play()
//            }
//        }
//    }
//
//    
//        deinit {
//            NotificationCenter.default.removeObserver(self)
//        }
//}
//
//
//
//
//// THIS WAS INSIDE THE SESSION ADD FOR THE STUPID OVERLAY THING
//
////        let mesh: MeshResource = .generatePlane(width: Float(imageSize.width), depth: Float(imageSize.height))
////
////        var material = SimpleMaterial()
////
////        if let baseResource = try? TextureResource.load(named: imageName) {
////                material.color = .init(tint: .white, texture: .init(baseResource))
////                material.color.tint = material.color.tint.withAlphaComponent(0.0)
////
////            }
////
////            material.roughness = 0.0
////            material.metallic = 0.0
////
////            model = ModelEntity(mesh: mesh, materials: [material])
////            if let model = model {
////                anchorEntity.addChild(model)
////                contentEntity.addChild(anchorEntity)
////                startOpacityAnimation(imageName)
////            }
//
//// END OF STUPID STUFF
//
////        private func startOpacityAnimation(_ name: String? = nil) {
////            var opacity: Float = 0.0
////            let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
////            timer.sink { [weak self] _ in
////                guard let self = self, let model = self.model else { return }
////
////                opacity += 0.01
////                if opacity >= 0.5 {
////                    opacity = 0.5
////                    guard let videoURL = Bundle.main.url(forResource: name, withExtension: "mp4") else { return }
////                    let avPlayer = AVPlayer(url: videoURL)
////                    let videoMaterial = VideoMaterial(avPlayer: avPlayer)
////                    model.model?.materials = [videoMaterial]
////                    avPlayer.play()
////                    self.cancellables.removeAll()
////                }
////
////                if var material = model.model?.materials.first as? SimpleMaterial {
////                    material.color.tint = material.color.tint.withAlphaComponent(CGFloat(opacity))
////                    model.model?.materials = [material]
////                }
////            }.store(in: &cancellables)
////    }
