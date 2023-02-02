//
//  ChatService.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

protocol ChatServiceDelegate: AnyObject {
    func recieveMessage(_ message: RecievedMessage)
}

class ChatService: NSObject {

    var token: String?
    var userId: String
    var webSocket: URLSessionWebSocketTask?

    init(_ userId: String) {
        self.userId = userId
        super.init()
        login()
    }

    weak var delegate: ChatServiceDelegate?

    func sendMessage(_ message: SentMessage) {
        let url = URL(string: "http://192.168.88.251/send")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]

        request.httpBody = try? JSONEncoder().encode(message)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                print("send response: \(String(data: data, encoding: .utf8) ?? "<error>")")
            }
        }

        task.resume()
    }

    func login() {
        let user = LoginRequest(username: userId, name: "", surname: "")

        let url = URL(string: "http://192.168.88.251/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.httpBody = try? JSONEncoder().encode(user)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data else {return}

            let respData = try? JSONDecoder().decode(LoginResponse.self, from: data)
            self?.token = respData?.token

            self?.listenForMessages()
        }

        task.resume()
    }

    func listenForMessages() {
        let url = URL(string: "ws://192.168.88.251/chat")!

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let webSocket = session.webSocketTask(with: request)
        self.webSocket = webSocket

        receiveWebSocketMessage()

        self.webSocket?.resume()
    }

    func receiveWebSocketMessage() {
        webSocket?.receive { [weak self] message in
            switch message {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.recieveMessageData(data)

                case .string(let string):
                    guard let data = string.data(using: .utf8) else {
                        print("received \(string)")
                        return
                    }
                    self?.recieveMessageData(data)

                default:
                    break
                }
            case .failure(let error):
                print(error)
            }

            self?.receiveWebSocketMessage()
        }
    }

    func recieveMessageData(_ data: Data) {
        guard let message = try? JSONDecoder().decode(RecievedMessage.self, from: data) else {return}
        DispatchQueue.main.async {
            self.delegate?.recieveMessage(message)
        }
    }
}

extension ChatService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("open")
    }


    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("closed")
    }
}
