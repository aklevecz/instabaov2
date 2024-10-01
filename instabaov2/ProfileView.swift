//
//  ProfileView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/30/24.
//

import SwiftUI


struct ProfileView: View {
    @ObservedObject private var authModel = AuthModel.shared
    
    @State private var phoneNumber: String = ""
    @State private var loadedImages: [String: UIImage] = [:]

    var body: some View {
        TopLineTitle(title: "Profile")

        if (authModel.currentUser == nil) {
            // AUTH FLOW
            if (authModel.showOTPView == false) {
                PhoneInputView(phoneNumber: $phoneNumber)
            }
            if (authModel.showOTPView) {
                OTPView(phoneNumber: phoneNumber)
            }
        } else {
            VStack {
                Text(authModel.currentUser?.username ?? "Loading...")
                    .font(.title)
                Text("Bao Secrets Found")
                    .fontWeight(.bold)
                    .padding(.top, 20)
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                       ForEach(authModel.collectedSecrets, id: \.self) { secret in
                           VStack {
                               if let uiImage = loadedImages[secret] {
                                   Image(uiImage: uiImage)
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .frame(width: 100, height: 100)
                                       .cornerRadius(10)
                               } else {
                                   ProgressView()
                                       .frame(width: 100, height: 100)
                                       .background(Color.gray.opacity(0.3))
                                       .cornerRadius(10)
                                       .onAppear {
                                           loadImage(for: secret)
                                       }
                               }
                               Text(secret)
                                   .font(.caption)
                                   .lineLimit(1)
                           }
                       }
                   }
                }
                Spacer()
                Button("Sign out") {
                    authModel.signOut()
                }.buttonStyle(GrowingButton())
            }.padding()
        }
    }
    private func loadImage(for secret: String) {
            ImageDataCache.shared.fetchImage(named: secret) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        self.loadedImages[secret] = uiImage
                    }
                }
            }
        }
}

#Preview {
    ProfileView()
}
