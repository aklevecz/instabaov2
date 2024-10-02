import SwiftUI

struct TopLineTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
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
    @EnvironmentObject var arManager: ARManager
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .gray
        UITabBar.appearance().tintColor = .blue
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ZStack(alignment: .top) {
                ChatView()
                    .padding(.top, 40)
                TopLineTitle(title: "Chat")
            }
            .tabItem {
                Image(systemName: "bubble.fill")
                Text("Chat")
            }
            .tag(NavTab.chat)
            
            VStack {
                InstaView()
            }.tabItem {
                Image(systemName: "photo.fill")
                Text("Instabao")
            }
            .tag(NavTab.instaBao)
            
            ZStack(alignment: .top) {
                ARViewer()
                TopLineTitle(title: "AR")
            }
            .tabItem {
                Image(systemName: "plus.viewfinder")
                Text("AR")
            }
            .tag(NavTab.ar)
            
            VStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(NavTab.profile)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ContentView()
}
