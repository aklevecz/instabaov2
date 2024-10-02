//
//  instabaov2App.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/23/24.
//

import SwiftUI

@main
struct instabaov2App: App {
    @StateObject private var arManager = ARManager()
    @StateObject private var messageModel = MessageModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(arManager).environmentObject(messageModel)
        }
    }
}
