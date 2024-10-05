//
//  SettingsManager.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 10/4/24.
//
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
    }
    
    func saveDeviceToken(_ deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
    }
    
    func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: "deviceToken")
    }
}
