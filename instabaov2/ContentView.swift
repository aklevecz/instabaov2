//
//  ContentView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/23/24.
//

import SwiftUI

enum NavTab {
    case chat
    case instaBao
    case ar
}

struct ContentView: View {
    @State var selection: NavTab = .chat
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .gray
        UITabBar.appearance().tintColor = .blue
    }
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Chat", systemImage:"bubble.fill", value: .chat) {
                ChatView()
            }
            
            Tab("Instabao", systemImage:"photo.fill", value:.instaBao) {
                InstaView()
            }
            
            Tab("AR", systemImage:"plus.viewfinder", value: .ar) {
                ARViewer()
            }
         }.edgesIgnoringSafeArea(.top)
    }
    
}

#Preview {
    ContentView()
}
