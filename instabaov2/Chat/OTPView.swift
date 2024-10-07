//
//  OTPView.swift
//  yaytso
//
//  Created by Ariel Klevecz on 4/17/24.
//

import SwiftUI

struct ResponseData: Codable {
    let token: String
    let phoneNumber: String
    let flowerId: Int
    let error: String?
}

struct VerifiedResponse: Codable {
    let token: String
    let phoneNumber: String
    let status: String
    let error: String?
}

struct OTPView:View {
    let phoneNumber: String
    
//    @ObservedObject var authModel = AuthModel.shared
    @EnvironmentObject var authModel: AuthModel
    
    @State private var showResendCode = false
    @State private var requestInProgress = false
    @State private var errorMessage = ""
    @State private var otp = ""
    

    var body: some View {
        VStack {
            Image("bao-head-120")
            Text("Verify Code")
            .font(.largeTitle)
            .fontWeight(.semibold)
            Text("Sooo what was that code?")
            .font(.title2)
            .padding()


            
            TextField("Code...", text: $otp)
            .keyboardType(.numberPad)
            .textFieldStyle(CustomRoundedTextFieldStyle())

            
            Button(action: {
                authModel.validateVerificationCode(phoneNumber: phoneNumber, otp: otp)
            }) {
                Text(authModel.requestInProgress ? "Sending" : "Verify")
            }.buttonStyle(GrowingButton())

            if (showResendCode && !authModel.requestInProgress) {
                Button("Resend code") {
                    authModel.sendVerificationRequest(phoneNumber: phoneNumber)
                }.padding()
            } else if (showResendCode) {
                ProgressView()
            }
            
            VStack {
                Text("Code was sent to: \(phoneNumber)")
                Button("Change phone number") {
                    authModel.showOTPView = false
                }
            }.padding()


        Text(errorMessage).foregroundColor(.red)
        }
//        .textFieldStyle(OvalTextFieldStyle())
            .padding()
            .onAppear {
                showResendCode = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    showResendCode = true
                }
            }

    }
}
#Preview {
    OTPView(phoneNumber: "1234567890").environmentObject(AuthModel())
}
