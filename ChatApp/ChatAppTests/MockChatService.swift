//
//  MockChatService.swift
//  ChatAppTests
//
//  Created by Patrick on 08.02.2023..
//

import Foundation

@testable import ChatApp

class MockChatService: ChatService {
    private var token: String?
    private var waitingForResponse = false {
        didSet {
            responseDelegate?.chatService(waitingForResponse)
        }
    }

    override init() {
        self.token = UserDefaults.standard.string(forKey: "CHAT_ID")
        super.init()
    }

//    weak var delegate: ChatServiceDelegate?
//    weak var actions: ChatServiceLogin?
//    weak var responseDelegate: ChatServiceResponse?

    override func sendMessage(_ message: SentMessage) {
//        let url = URL(string: "http://192.168.88.251/send")!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = ["mojToken": token ?? ""]
//
//        request.httpBody = try? JSONEncoder().encode(message)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                print("send response: \(String(data: data, encoding: .utf8) ?? "<error>")")
//            }
//        }
//
//        task.resume()
        print(message)
    }

    override func login(_ model: LoginRequest) {

        guard !model.username.isEmpty else {return}
        guard !model.surname.isEmpty else {return}
        guard !model.name.isEmpty else {return}

        let response = LoginResponse(token: UUID().uuidString)
        let userDefaults = UserDefaults.standard
        userDefaults.set(response.token, forKey: "CHAT_ID")
        self.loginDelegate?.recieveId(response.token)
    }

    override func listenForMessages() {
//        let url = URL(string: "ws://192.168.88.251/chat")!
//        var request = URLRequest(url: url)
//        request.allHTTPHeaderFields = ["mojToken": token ?? ""]
//        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
//        let webSocket = session.webSocketTask(with: request)
//        self.webSocket = webSocket
//
//        receiveWebSocketMessage()
//
//        self.webSocket?.resume()
    }

    override func receiveWebSocketMessage() {
//        webSocket?.receive { [weak self] message in
//            switch message {
//            case .success(let message):
//                switch message {
//                case .data(let data):
//                    self?.recieveMessageData(data)
//
//                case .string(let string):
//                    guard let data = string.data(using: .utf8) else {
//                        print("received \(string)")
//                        return
//                    }
//                    self?.recieveMessageData(data)
//
//                default:
//                    break
//                }
//            case .failure(let error):
//                print(error)
//            }
//
//            self?.receiveWebSocketMessage()
//        }
    }

    override func recieveMessageData(_ data: Data) {
        let message = RecievedMessage(
            sourceUsername: "someuser",
            timestamp: Date.now.timeIntervalSince1970,
            content: "test message")
        delegate?.chatService(didRecieve: message)
    }

    override func fetchActiveUsers() {
        let activeUsers = [User(username: "asddas"), User(username: "asjdhjkas"), User(username: "user")]
        usersDelegate?.chatService(didRecieve: activeUsers)
    }
}
