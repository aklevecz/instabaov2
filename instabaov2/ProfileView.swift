//
//  ProfileView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/30/24.
//

import SwiftUI


struct ProfileView: View {
//    @ObservedObject private var authModel = AuthModel.shared
    @EnvironmentObject private var arManager: ARManager
    @EnvironmentObject private var authModel: AuthModel
    @Environment(\.appDelegate) var appDelegate  // Add this line

    @State private var phoneNumber: String = ""
    @State private var loadedImages: [String: UIImage] = [:]
    
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {


        if (authModel.currentUser == nil) {
            if (authModel.showOTPView == false) {
                PhoneInputView(phoneNumber: $phoneNumber)
            }
            if (authModel.showOTPView) {
                OTPView(phoneNumber: phoneNumber)
            }
        } else {
            VStack {
                HStack{
                    Image("bao-profile-icon-60")
                }
                Text(authModel.currentUser?.username ?? "Loading...")
                    .font(.title)
                Toggle("Enable Notifications", isOn: $settingsManager.notificationsEnabled)
                    .onChange(of: settingsManager.notificationsEnabled) { newValue in
                    if newValue {
                        guard let phoneNumber = authModel.currentUser?.phoneNumber else { return }
                        appDelegate.registerForPushNotifications(phoneNumber)
                    } else {
                        // Optionally, add logic to disable notifications
                        print("Notifications disabled")
                    }
                }
                .padding()
                .cornerRadius(10)
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
                Button("Reload AR Configuration") {
                    arManager.fetchActiveConfig()
                }
                Button("Sign out") {
                    authModel.signOut()
                }.buttonStyle(GrowingButton())
            }.padding()
            .onDisappear() {
                // REFACTOR
//                authModel.showOTPView = false
            }
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
    ProfileView().environmentObject(AuthModel()).environmentObject(ARManager())
}
