//
//  AuthModel.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/25/24.
//
import SwiftUI

struct AppUser: Codable, Equatable {
    let id: String
    let username: String
    let phoneNumber: String
    // Add any other properties you need
}

struct PhoneResponseData: Codable {
    let phoneNumber: String?
    let action: String?
    let error: String?
}

class AuthModel: ObservableObject {
    static let shared = AuthModel()

    private let tokenKey = "UserAccessToken"

    @Published var currentUser: AppUser? {
        didSet {
            saveUser()
        }
    }
    
    @Published var collectedSecrets: [String] = []

    
    @Published var phoneNumber: String = ""
    @Published var requestInProgress: Bool = false
    @Published var errorMessage: String = ""
    @Published var showOTPView: Bool = false
    
    
    init() {
        loadUser()
        
        loadCollectedSecrets()
    }
    
    private func saveUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: "CurrentUser")
        }
    }
    
    private func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: "CurrentUser"),
           let user = try? JSONDecoder().decode(AppUser.self, from: userData) {
            self.currentUser = user
        }
    }
    
    private func saveCollectedSecrets() {
        if let encoded = try? JSONEncoder().encode(collectedSecrets) {
            UserDefaults.standard.set(encoded, forKey: "CollectedSecrets")
        }
    }
    
    private func loadCollectedSecrets() {
        if let secretsData = UserDefaults.standard.data(forKey: "CollectedSecrets"),
           let secrets = try? JSONDecoder().decode([String].self, from: secretsData) {
            self.collectedSecrets = secrets
        }
    }
    
    func saveSecretsOnServer(_ secrets: [String]) {
        let urlString = "https://main.instabao-be.pages.dev/secrets"
        let token = getToken()
        
        // Create URL from string
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // Create URLRequest and set method to POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Create header with token
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Put secrets in the body
        let body: [String: Any] = ["secrets": secrets]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        // Make POST request to the URL
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle response or error
            if let error = error {
                print("Error making request: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                // Optionally handle response data
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response data: \(responseString)")
                }
            }
        }
        task.resume()
    }

    
    func updateCollectedSecrets(_ secrets: [String]) {
        DispatchQueue.main.async {
            self.collectedSecrets = secrets
            self.saveSecretsOnServer(secrets)
            self.saveCollectedSecrets()
        }
    }
    
    func signOut() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
//        UserDefaults.standard.removeObject(forKey: "CollectedSecrets")
        // Add any other cleanup you need
    }
    
    func updateUser(_ user: AppUser) {
        DispatchQueue.main.async {
            self.currentUser = user
        }
    }
    
    // Add other authentication-related methods as needed
    func signIn(username: String, password: String) {
        // Implement your sign-in logic here
        // If successful, create and set the currentUser
        // For example:
        // if authenticateUser(username: username, password: password) {
        //     let newUser = AppUser(id: "generatedID", username: username)
        //     updateUser(newUser)
        // }
    }
    
    func storeToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    func sendVerificationRequest(phoneNumber: String) {
            guard let url = URL(string: "https://los.baos.haus/messaging/verification") else {
                return
            }
            
            let parameters = ["phoneNumber": phoneNumber]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            
            DispatchQueue.main.async {
                self.requestInProgress = true
            }
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    self?.requestInProgress = false
                    self?.errorMessage = ""
                }
                
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let responseData = try decoder.decode(PhoneResponseData.self, from: data)
                        
                        DispatchQueue.main.async {
                            if let error = responseData.error {
                                self?.errorMessage = error
                            } else {
                                self?.showOTPView = true
                            }
                        }
                        print("Response: \(data)")
                    } catch {
                        print("Error decoding response: \(data)")
                    }
                }
            }.resume()
        }
    
    func validateVerificationCode(phoneNumber: String, otp: String) {
       guard let url = URL(string: "https://los.baos.haus/messaging/verification") else {
           return
       }

        let parameters = ["phoneNumber": phoneNumber, "code": otp]
       guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
           return
       }
       
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.httpBody = jsonData
        
        DispatchQueue.main.async {
            self.requestInProgress = true
        }
       
       URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.requestInProgress = false
                self.errorMessage = ""
            }
           // Handle the response here
           if let error = error {
               print("Error: \(error)")
           } else if let data = data {
               // Process the response data here
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(ResponseData.self, from: data)
                DispatchQueue.main.async {
                    if (responseData.error != nil ) {
                        self.errorMessage = responseData.error ?? "Code may be invalid"
                    } else {
                        print("Success")
                        AuthModel.shared.storeToken(responseData.token)
                        // or get some username and id from the response
                        let user = AppUser(id:phoneNumber, username: phoneNumber, phoneNumber: phoneNumber)
                        AuthModel.shared.updateUser(user)
                    }
                }
            } catch {
                self.errorMessage = "Code may be invalid"
                print("Error decoding JSON: \(error)")
            }

           }
       }.resume()
    }
}
