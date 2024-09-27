//
//  ARView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//
import SwiftUI

struct ARViewer: View {
//    @StateObject private var arModel = ARModel()

    var body: some View {
        ZStack {
//            ARViewWrapper(arView: arModel.arView)
//                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("AR Camera View")
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()
            }
        }
//        .onAppear {
//            arModel.setup()
//        }
//        .onDisappear {
//            arModel.stopSession()
//        }
    }
}

#Preview {
    ARViewer()
}
