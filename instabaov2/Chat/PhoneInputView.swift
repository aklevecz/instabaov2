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

struct CustomRoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .font(.system(size:28))
            .padding()
            .multilineTextAlignment(.center)

    }
}

struct PhoneInputView: View {
    @Binding var phoneNumber: String
    
//    @ObservedObject var authModel = AuthModel.shared
    @EnvironmentObject var authModel: AuthModel

    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .dismissKeyboardOnTap()
            VStack {
                    Image("bao-head-120")
                    Text("Sign in")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    Text("Enter your phone number to receive a code")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .padding(.horizontal,12)
                
                    TextField("Phone number", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .textFieldStyle(CustomRoundedTextFieldStyle())

                
                Button(action: {
                        authModel.sendVerificationRequest(phoneNumber: phoneNumber)
                    }) {
                        Text(authModel.requestInProgress ? "Sending" : "Send Code")
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
            PhoneInputView(phoneNumber: $phoneNumber).environmentObject(AuthModel())
        }
    }
    return StatePreview()
}
