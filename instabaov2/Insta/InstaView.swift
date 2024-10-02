import SwiftUI
import AVKit

struct InstaView: View {
    @ObservedObject private var instaModel = InstaModel()

    var body: some View {
        TopLineTitle(title: "Instabao")
        ScrollView {
            LazyVStack(spacing: 100) {
                ForEach(instaModel.displayedItems) { item in
                    VStack(spacing: 0) {
                        InstaItem(item: item)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.description)
                                .font(.headline)
                            HStack {
                                Text(item.city)
                                Text(item.state)
                            }
                            .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }.frame(minHeight:600)
                }
                if !instaModel.displayedItems.isEmpty {
                    ProgressView()
                        .onAppear {
                            instaModel.loadNextPage()
                        }
                }
            }
//            .padding()
        }
        .task {
            await instaModel.fetchItems()
        }
        .refreshable {
            Task {
                await instaModel.fetchItems()
            }
        }
    }
}

#Preview {
    InstaView()
}
