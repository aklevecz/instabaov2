//
//  LoadingBubble.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 10/4/24.
//

import SwiftUI

struct LoadingBubble: View {
    @State private var opacity: Double = 0.5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { _ in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .opacity(opacity)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

#Preview {
    LoadingBubble()
}
