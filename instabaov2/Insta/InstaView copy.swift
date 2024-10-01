////
////  InstaView.swift
////  instabaov2
////
////  Created by Ariel Klevecz on 9/24/24.
////
//
//import SwiftUI
//
//struct InstaView2: View {
//    @ObservedObject private var instaModel = InstaModel()
//    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: 1)
//
//    var body: some View {
//        VStack {
//            ScrollView {
//                LazyVGrid(columns: gridColumns, spacing: 100) {
//                    ForEach(instaModel.items) { item in
//                        VStack {
//                            GeometryReader { geo in
////                                NavigationLink(destination: DetailView(item: item)) {
//                                    InstaItem(width: geo.size.width, height: geo.size.height, item: item)
////                                }
//                            }
//                            .cornerRadius(1.0)
////                            .aspectRatio(1, contentMode: .fit)
////                            .frame(height: 700, alignment: .topTrailing)
//                            
//                            VStack(alignment:.leading) {
//                                HStack {
//                                    Text(item.description)
//                                        .font(.system(size: 20, weight: .bold, design: .default))
//                                }
//                                .frame(maxWidth:.infinity, alignment: .leading)
//                                
//                                HStack {
//                                    Text(item.city)
//                                    Text(item.state)
//                                }
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                //                            Text(formattedDate(from: item.creationDate))
//                                //                            .foregroundColor(.gray)
//                                //                            .padding(0)
//                                
//                            }
////                            .padding(.horizontal, 12)
////                            .padding(.vertical, 5)
//                            
//                        }
////                        .background(Color.red)
//                        
//                    }
//                }
//            }
//        }.task {
//            await instaModel.fetchItems()
//        }
//    }
//
//}
//
//#Preview {
//    InstaView()
//}
