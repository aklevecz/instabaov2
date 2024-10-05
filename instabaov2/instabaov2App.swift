//
//  instabaov2App.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/23/24.
//

import SwiftUI

struct AppDelegateKey: EnvironmentKey {
    static let defaultValue: AppDelegate = AppDelegate()
}

extension EnvironmentValues {
    var appDelegate: AppDelegate {
        get { self[AppDelegateKey.self] }
        set { self[AppDelegateKey.self] = newValue }
    }
}

@main
struct instabaov2App: App {
    @StateObject private var arManager = ARManager()
    @StateObject private var messageModel = MessageModel()
    @StateObject private var authModel = AuthModel()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(arManager).environmentObject(messageModel).environmentObject(authModel)
                .environment(\.appDelegate, appDelegate)  // Add this line

                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var settingsManager = SettingsManager.shared
    private var currentPhoneNumber: String?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(deviceTokenString)")
        print("Saved device token: \(settingsManager.getDeviceToken())")
        settingsManager.saveDeviceToken(deviceTokenString)
        print("New saved device token: \(settingsManager.getDeviceToken())")
        print("currentPhoneNumber: \(currentPhoneNumber)")
        // Send this token to your server
        guard let url = URL(string: "https://instabao-be.pages.dev/notifications/register") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "token": deviceTokenString,
            "phoneNumber": currentPhoneNumber
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing parameters: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending token to server: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Server response: \(responseString ?? "")")
            }
        }
        
        task.resume()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func registerForPushNotifications(_ phoneNumber: String) {
        currentPhoneNumber = phoneNumber
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
