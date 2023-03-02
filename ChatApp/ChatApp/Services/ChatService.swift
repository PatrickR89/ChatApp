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

protocol ChatServiceUsersDelegate: AnyObject {
    func service(didRecieve users: [User])
}

protocol ChatServiceActions: AnyObject {
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
            DispatchQueue.main.async {
                self.responseDelegate?.chatService(self.waitingForResponse)
            }
        }
    }

    override init() {
        self.token = UserDefaults.standard.string(forKey: "CHAT_ID")
        super.init()
    }

    weak var delegate: ChatServiceDelegate?
    weak var actions: ChatServiceActions?
    weak var responseDelegate: ChatServiceResponse?
    weak var usersDelegate: ChatServiceUsersDelegate?

    func sendMessage(_ message: SentMessage) {
        let url = URL(string: "http://192.168.88.251/send")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]

        request.httpBody = try? JSONEncoder().encode(message)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.actions?.errorOccured(error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                if response.statusCode >= 400 && response.statusCode < 500 {
                    self?.actions?.errorOccured("Error in request")
                } else if response.statusCode >= 500 {
                    self?.actions?.errorOccured("Error occured on server")
                }

                return
            }

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

            if let error = error {
                self?.waitingForResponse = false
                self?.actions?.errorOccured(error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                self?.waitingForResponse = false
                if response.statusCode == 403 || response.statusCode == 401 {
                    self?.actions?.errorOccured("Authentication failed")
                } else if response.statusCode >= 400 && response.statusCode < 500 {
                    self?.actions?.errorOccured("Error in request")
                } else if response.statusCode >= 500 {
                    self?.actions?.errorOccured("Error occured on server")
                }

                return
            }

            guard let data = data else {
                self?.actions?.errorOccured("Error occured while fetching data")
                return
            }

            guard let respData = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                self?.actions?.errorOccured("Error in retrieved data")
                return
            }
            let userDefaults = UserDefaults.standard
            userDefaults.set(respData.token, forKey: "CHAT_ID")

            self?.waitingForResponse = false
            self?.actions?.recieveId(respData.token)
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

    func fetchActiveUsers() {
        let url = URL(string: "http://192.168.88.251/users?status=active")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                self?.waitingForResponse = false
                self?.actions?.errorOccured(error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                self?.waitingForResponse = false
                if response.statusCode >= 400 && response.statusCode < 500 {
                    self?.actions?.errorOccured("Error in request")
                } else if response.statusCode >= 500 {
                    self?.actions?.errorOccured("Error occured on server")
                }

                return
            }

            guard let data = data else {
                self?.actions?.errorOccured("Error occured while fetching data")
                return
            }

            guard let users = try? JSONDecoder().decode([User].self, from: data) else {
                self?.actions?.errorOccured("Error in retrieved data")
                return
            }

            DispatchQueue.main.async {
                self?.usersDelegate?.service(didRecieve: users)
            }
        }

        task.resume()
    }
}

extension ChatService: LoginControllerDelegate {
    func loginView(didRequestLoginFor user: LoginRequest) {
        login(user)
    }
}

extension ChatService: ActiveUsersControllerDelegate {
    func activeUsersControllerDidRequestUsers() {
        fetchActiveUsers()
    }
}

extension ChatService: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?) {
            print("open")
        }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?) {
            print("closed")
        }
}
