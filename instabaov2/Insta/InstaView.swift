import SwiftUI
import AVKit
//baostagram/7F48C641-694E-4961-B12D-603C15336282
struct InstaView: View {
    @ObservedObject private var instaModel = InstaModel()

    var body: some View {
        Image("bao-insta-head-60")
        ScrollView {
            LazyVStack(spacing: 100) {
                ForEach(instaModel.displayedItems) { item in
                    VStack(spacing: 0) {
                        InstaItem(item: item)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.description)
                                .font(.system(size: 24, weight: .light))
                            HStack {
                                Text(item.city)
                                Text(item.state)
                            }
                            .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
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
