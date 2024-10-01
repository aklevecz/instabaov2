//
//  ChatView.swift
//  instabaov2
//
//  Created by Ariel Klevecz on 9/24/24.
//

import SwiftUI

struct ChatView: View {
    @Namespace var animation
    @FocusState private var isFocused: Bool
    @State private var text = ""
    @State private var sentMessage: Message?
   
    @ObservedObject private var messageModel = MessageModel()
    @ObservedObject private var authModel = AuthModel.shared
    
    @State private var showOTPView: Bool = false
    
    @State private var phoneNumber = "1234567890"
    @State private var requestInProgress = false
    @State private var errorMessage = ""
    
//    @Binding var messages: [Message]
    
//    public init(messages: Binding<[Message]>) {
//            _messages = messages
//    }

    var body: some View {
        if requestInProgress {
            ProgressView()
                .scaleEffect(5)
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        if (authModel.currentUser == nil) {
            // AUTH FLOW
            if (authModel.showOTPView == false) {
                PhoneInputView(phoneNumber: $phoneNumber)
            }
            if (authModel.showOTPView) {
                OTPView(phoneNumber: phoneNumber)
            }
        }
        if (authModel.currentUser?.phoneNumber != nil) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(messageModel.messages) { message in
                            MessageBubble(message: message)
                                .matchedGeometryEffect(id: message.id, in: animation)
                                .id(message.id)
                                .padding(.bottom, 8)
                        }
                    }.padding()
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    textFieldContent(with: proxy)
                }
                .onChange(of: messageModel.messages) { _, messages in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id)
                    }
                }
                .onAppear {
                    messageModel.fetchMessages()
                }
            }
        }
    }
    
    private func textFieldContent(with proxy: ScrollViewProxy) -> some View {
            HStack(alignment: .bottom) {
                TextField("Message", text: $text, axis: .vertical)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .focused($isFocused)
                    .onSubmit {
                        isFocused = true
                        submit()
                    }
                    .onChange(of: isFocused) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(messageModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                Button(action: submit) {
                    Image(systemName: "arrow.up.circle.fill")
                        .imageScale(.large)
                }
                .tint(.primary)
                .disabled(text.isEmpty)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            .overlay(Color(.separator), in: .rect(cornerRadius: 18).stroke())
            .overlay(alignment: .leading) {
                if let sentMessage {
                    MessageBubble(message: sentMessage)
                        .matchedGeometryEffect(id: sentMessage.id, in: animation)
                }
            }
            .padding()
            .background {
                Rectangle()
                    .fill(.background.opacity(0.5))
                    .background(.bar)
                    .ignoresSafeArea()
            }
        }
        
        private func submit() {
            guard !text.isEmpty else { return }
            let message = Message(direction: .outgoing, kind: .text(text))
            messageModel.sendMessage(id: "14159671642", message:text)
            text = ""

            sentMessage = message
            withAnimation(.smooth(duration: 0.2)) {
                sentMessage = nil
                messageModel.messages.append(message)
            }
        }
}

#Preview {
    struct StatePreview: View {
        var body: some View {
            NavigationStack {
                ChatView()
                    .navigationTitle("Chat")
            }
        }
    }
    return StatePreview()
}
