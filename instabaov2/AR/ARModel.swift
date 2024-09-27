//
//  ARModel.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/25/24.
//
import SwiftUI
import ARKit
import RealityKit
import AVKit
import Combine

struct ARViewWrapper: UIViewRepresentable {
    let arView: ARView

    func makeUIView(context: Context) -> ARView {
        arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

class ARModel:NSObject, ObservableObject, ARSessionDelegate {
//    var arView = ARView(frame: .zero)
    var contentEntity = AnchorEntity()
    private var cancellables: Set<AnyCancellable> = []
    private var model: ModelEntity?
    
    func setup() {
//        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "ImageTracking", bundle: nil) else {
//            fatalError("Missing expected asset catalog resources.")
//        }
//        arView.scene.addAnchor(contentEntity)
//        let configuration = ARImageTrackingConfiguration()
//        configuration.trackingImages = referenceImages
//        configuration.maximumNumberOfTrackedImages = 1
//        arView.session.delegate = self
//        startSession(with: configuration)
    }
    
    func startSession(with configuration: ARConfiguration) {
//        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    func stopSession() {
//        arView.session.pause()
    }
    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        guard let imageAnchor = anchors.first as? ARImageAnchor else { return }
//        
//        print("Image anchor: \(imageAnchor.referenceImage.name)")
//        guard let videoURL = Bundle.main.url(forResource: "baodj", withExtension: "mp4") else { return }
//        let avPlayer = AVPlayer(url: videoURL)
//        let videoMaterial = VideoMaterial(avPlayer: avPlayer)
//        let referenceImage = imageAnchor.referenceImage
//        let imageSize = referenceImage.physicalSize
//        let anchorEntity = AnchorEntity(anchor: imageAnchor)
//
////        let scaleX = 1.0
////        let scaleY = 1.0
////        let entity = ModelEntity(mesh: .generatePlane(width: Float(imageSize.width * scaleX), depth: Float(imageSize.height * scaleY)), materials:[videoMaterial])
////        anchorEntity.addChild(entity)
////        contentEntity.addChild(anchorEntity)
////        avPlayer.play()
//        
//        let mesh: MeshResource = .generatePlane(width: Float(imageSize.width), depth: Float(imageSize.height))
//                
//        var material = SimpleMaterial()
//
//            if let baseResource = try? TextureResource.load(named: "baodj") {
//                material.color = .init(tint: .white, texture: .init(baseResource))
//                material.color.tint = material.color.tint.withAlphaComponent(0.0)
//
//            }
//
//            material.roughness = 0.0
//            material.metallic = 0.0
//
//            model = ModelEntity(mesh: mesh, materials: [material])
//            if let model = model {
//                anchorEntity.addChild(model)
//                contentEntity.addChild(anchorEntity)
//                startOpacityAnimation()
//            }
//        }

        private func startOpacityAnimation() {
            var opacity: Float = 0.0
            let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
            timer.sink { [weak self] _ in
                guard let self = self, let model = self.model else { return }
                
                opacity += 0.01
                if opacity >= 1.0 {
                    opacity = 1.0
                    guard let videoURL = Bundle.main.url(forResource: "baodj", withExtension: "mp4") else { return }
                    let avPlayer = AVPlayer(url: videoURL)
                    let videoMaterial = VideoMaterial(avPlayer: avPlayer)
                    model.model?.materials = [videoMaterial]
                    avPlayer.play()
                    self.cancellables.removeAll()
                }
                
                if var material = model.model?.materials.first as? SimpleMaterial {
                    material.color.tint = material.color.tint.withAlphaComponent(CGFloat(opacity))
                    model.model?.materials = [material]
                }
            }.store(in: &cancellables)
    }
}

