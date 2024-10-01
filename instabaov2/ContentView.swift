//
//  ContentView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/23/24.
//

import SwiftUI

struct TopLineTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
//            .background(Color(UIColor.systemBackground))
//            .shadow(color: Color.black.opacity(0.1), radius: 1, y: 1)
    }
}

enum NavTab {
    case chat
    case instaBao
    case ar
    case profile
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
                ZStack(alignment: .top) {
                    ChatView()
                        .padding(.top, 40)
                    TopLineTitle(title: "Chat")
                }
            }
            
            Tab("Instabao", systemImage:"photo.fill", value:.instaBao) {
                InstaView()
            }
            
            Tab("AR", systemImage:"plus.viewfinder", value: .ar) {
                TopLineTitle(title: "AR")
                ARViewer()
            }
            
            Tab("Profile", systemImage:"person.fill", value: .profile) {
                ProfileView()
            }
         }.edgesIgnoringSafeArea(.top)
    }
    
}

#Preview {
    ContentView()
}
