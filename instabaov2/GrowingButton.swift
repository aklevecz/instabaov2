//
//  GrowingButton.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/26/24.
//
import SwiftUI

struct GrowingButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .border(colorScheme == .light ? Color.black : Color.white, width:2)
            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            .fontWeight(.bold)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
