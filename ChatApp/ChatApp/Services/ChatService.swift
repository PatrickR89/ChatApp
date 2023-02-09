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

protocol ChatServiceLogin: AnyObject {
    func recieveId(_ id: String)
    func errorOccured(_ error: String)
}

protocol ChatServiceResponse: AnyObject {
    func chatService(_ isWaitingForResponse: Bool)
}

class ChatService: NSObject {

    private var token: String?
    private var webSocket: URLSessionWebSocketTask?
    private var waitingForResponse = false {
        didSet {
            responseDelegate?.chatService(waitingForResponse)
        }
    }

    override init() {
        self.token = UserDefaults.standard.string(forKey: "CHAT_ID")
        super.init()
    }

    weak var delegate: ChatServiceDelegate?
    weak var loginDelegate: ChatServiceLogin?
    weak var responseDelegate: ChatServiceResponse?

    func sendMessage(_ message: SentMessage) {
        let url = URL(string: "http://192.168.88.251/send")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]

        request.httpBody = try? JSONEncoder().encode(message)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                print("send response: \(String(data: data, encoding: .utf8) ?? "<error>")")
            }
        }

        task.resume()
    }

    func login(_ model: LoginRequest) {

        let url = URL(string: "http://192.168.88.251/login")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(model)
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            guard error == nil else {
                DispatchQueue.main.async { [weak self] in
                    self?.waitingForResponse = false
                    self?.loginDelegate?.errorOccured(error!.localizedDescription)
                }

                return
            }

            guard let data = data else {return}

            guard let respData = try? JSONDecoder().decode(LoginResponse.self, from: data) else {return}
            let userDefaults = UserDefaults.standard
            userDefaults.set(respData.token, forKey: "CHAT_ID")

            self?.waitingForResponse = false
            self?.loginDelegate?.recieveId(respData.token)
            self?.listenForMessages()
        }

        waitingForResponse = true

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

extension ChatService: LoginViewDelegate {
    func loginView(didRequestLoginFor user: LoginRequest) {
        login(user)
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
