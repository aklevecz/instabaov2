import SwiftUI

struct TopLineTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .padding()
//            .frame(maxWidth: .infinity)
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
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var messageModel: MessageModel
    
    init() {
        UITabBar.appearance().unselectedItemTintColor = .gray
        UITabBar.appearance().tintColor = .blue
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ZStack(alignment: .top) {
                Image("bao-head-60")
                ChatView()
                    .padding(.top, 70)
//                TopLineTitle(title: "Chat")
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
                Image("bao-ar-icon-60")
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
        .onChange(of: authModel.currentUser) { newUser in  // Removed optional chaining
            print("User changed: \(String(describing: newUser?.phoneNumber))")
            if let id = newUser?.phoneNumber {
                messageModel.fetchMessages(id: id)
            } else {
                authModel.showOTPView = false
            }
        }
        .onAppear {
            if let id = authModel.currentUser?.phoneNumber {
                messageModel.fetchMessages(id: id)
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(AuthModel()).environmentObject(ARManager()).environmentObject(MessageModel())
}
