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

    func fetchMessages(id: String) {
            Task {
                do {
                    let messages = try await fetchMessagesAsync(id: id)
                    print(messages)
                    await MainActor.run {
                        self.messages = messages
                    }
                } catch {
                    print("Error fetching messages: \(error)")
                }
            }
        }

        private func fetchMessagesAsync(id: String) async throws -> [Message] {
            guard let url = URL(string: "\(urlString)?id=\(id)") else {
                throw URLError(.badURL)
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let apiMessages = try JSONDecoder().decode([APIMessage].self, from: data)
            return transformToMessages(apiMessages)
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
//            print(jsonData)
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
