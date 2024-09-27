//
//  PhoneInputView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/25/24.
//

import SwiftUI

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

struct PhoneInputView: View {
    @Binding var phoneNumber: String
    
    @ObservedObject var authModel = AuthModel.shared

    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .dismissKeyboardOnTap()
            VStack {
                    Text("Enter your phone number")
                        .font(.custom("PragmataProFraktur-Bold", size: 30))
    //                    .padding()
                    TextField("...", text: $phoneNumber)
                        .font(.custom("PragmataProFraktur", size: 35))
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Continue") {
                        authModel.sendVerificationRequest(phoneNumber: phoneNumber)
                    }
                    .buttonStyle(GrowingButton())
                    .disabled(authModel.requestInProgress)
                    
                    if !authModel.errorMessage.isEmpty {
                        Text(authModel.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
            }.dismissKeyboardOnTap()
        }
    }

}

#Preview {
    struct StatePreview: View {
        @State var phoneNumber: String = ""
        var body: some View {
            PhoneInputView(phoneNumber: $phoneNumber)
        }
    }
    return StatePreview()
}
