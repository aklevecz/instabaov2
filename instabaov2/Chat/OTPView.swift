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
    
    @ObservedObject var authModel = AuthModel.shared
    
    @State private var requestInProgress = false
    @State private var errorMessage = ""
    @State private var otp = "1234"
    

    var body: some View {
        VStack {
            Text("Verify Code")
            .font(.largeTitle)
            .fontWeight(.heavy)
            Text("Sooo what was that code?")
            .font(.title2)
            .fontWeight(.heavy)
            .padding()
        

            
            TextField("Code...", text: $otp)
            .keyboardType(.numberPad)
            .padding()
            
            Button(action: {
                authModel.validateVerificationCode(phoneNumber: phoneNumber, otp: otp)
            }) {
                Text(authModel.requestInProgress ? "Sending" : "Verify")
            }.buttonStyle(GrowingButton())


        Text(errorMessage).foregroundColor(.red)
        }
//        .textFieldStyle(OvalTextFieldStyle())
            .padding()

    }
}
#Preview {
    OTPView(phoneNumber: "1234567890")
}
