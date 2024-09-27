//
//  MessageModel.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/23/24.
//

import SwiftUI
import Combine

struct APIMessage: Codable {
    let content: String
    let role: String
}

struct SendMessageRequest: Codable {
    let id: String
    let message: String
}

class MessageModel: ObservableObject {
    @Published var messages: [Message] = []
    private var cancellables: Set<AnyCancellable> = []
    private let urlString = "https://los.baos.haus/messaging/bao-convo"

    func fetchMessages() {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [APIMessage].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] apiMessages in
//                print(apiMessages)
                self?.messages = self?.transformToMessages(apiMessages) ?? []
            }
            .store(in: &cancellables)
    }
    
    func sendMessage(id: String, message: String) {
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }
            
            let request = SendMessageRequest(id: id, message: message)
            
            guard let jsonData = try? JSONEncoder().encode(request) else {
                print("Error: Couldn't encode request")
                return
            }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            print(jsonData)
            URLSession.shared.dataTaskPublisher(for: urlRequest)
                .map(\.data)
                .decode(type: [APIMessage].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                } receiveValue: { [weak self] apiMessages in
                    self?.messages = self?.transformToMessages(apiMessages) ?? []
                }
                .store(in: &cancellables)
        }
    
    private func transformToMessages(_ apiMessages: [APIMessage]) -> [Message] {
        return apiMessages.enumerated().map { index, apiMessage in
            // Alternate between incoming and outgoing messages
            let direction: Message.Direction = apiMessage.role == "user" ? .outgoing : .incoming
            return Message(direction: direction, kind: .text(apiMessage.content))
        }
    }
}
