//
//  ARView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//
import SwiftUI

struct ARViewer: View {
    @StateObject private var arModel = ARModel()
    @EnvironmentObject var arManager: ARManager
    @EnvironmentObject var authModel: AuthModel

    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading configuration...")
            } else {
//                ARViewWrapper(arView: arModel.arView)
//                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                }
            }
        }
        .task {
            print("Running AR Setup")
            guard let config = arManager.config else {
                print("Missing config :(")
                return
            }
            arModel.setup(config: config, authModel: authModel)
            isLoading = false
        }
        .onDisappear {
            arModel.stopSession()
        }
    }
}

#Preview {
    ARViewer()
}
