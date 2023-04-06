//
//  ChatService.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation

protocol ChatServiceDelegate: AnyObject {
    func recieveMessage(_ message: RecievedMessage)
    func chatService(didSendMessage id: UUID, to user: String, withSuccess success: Bool)
}

protocol ChatServiceUsersDelegate: AnyObject {
    func service(didRecieve users: [User])
}

protocol ChatServiceActions: AnyObject {
    func recieveId(for username: String, token id: String)
    func registeredUser(_ user: LoginRequest)
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

    private var pendingMessages = [PendingMessage]()

    override init() {
        self.token = UserDefaults.standard.string(forKey: "CHAT_ID")
        super.init()
    }

    weak var delegate: ChatServiceDelegate?
    weak var actions: ChatServiceActions?
    weak var responseDelegate: ChatServiceResponse?
    weak var usersDelegate: ChatServiceUsersDelegate?

    func setToken(_ token: String) {
        self.token = token
    }

    func sendMessage(_ message: SentMessage, messageId: UUID) {
        let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.sendMessageAPI)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]

        request.httpBody = try? JSONEncoder().encode(message)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else {
                return
            }
            if let error = error {
                let pendingMessage = PendingMessage(message: message, id: messageId)
                self.pendingMessages.append(pendingMessage)
                self.backthreadMessageOutput()
                self.delegate?.chatService(didSendMessage: messageId, to: message.chatId, withSuccess: false)
                self.actions?.errorOccured(error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                let pendingMessage = PendingMessage(message: message, id: messageId)
                self.pendingMessages.append(pendingMessage)
                self.backthreadMessageOutput()

                self.delegate?.chatService(didSendMessage: messageId, to: message.chatId, withSuccess: false)
                if response.statusCode >= 400 && response.statusCode < 500 {
                    self.actions?.errorOccured("Error in request")
                } else if response.statusCode >= 500 {
                    self.actions?.errorOccured("Error occured on server")
                }

                return
            }
            self.delegate?.chatService(didSendMessage: messageId, to: message.chatId, withSuccess: true)
            if let data = data {
                print("send response: \(String(data: data, encoding: .utf8) ?? "<error>")")
            }
        }

        task.resume()
    }

    func backthreadMessageOutput() {
        guard !pendingMessages.isEmpty else {
            return
        }
        guard let message = pendingMessages.first else {
            return
        }

        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 2) { [weak self] in
            let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.sendMessageAPI)")!

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["mojToken": self?.token ?? ""]
            let outputMessage = SentMessage(content: message.content, chatId: message.chatId)
            request.httpBody = try? JSONEncoder().encode(outputMessage)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    self?.backthreadMessageOutput()
                    return
                }

                guard let response = response as? HTTPURLResponse else { return }
                guard response.statusCode == 200 else {

                    self?.backthreadMessageOutput()
                    return
                }

                if let data = data {
                    print("send response: \(String(data: data, encoding: .utf8) ?? "<error>")")
                }
                self?.delegate?.chatService(didSendMessage: message.id, to: message.chatId, withSuccess: true)
                self?.pendingMessages.removeFirst()
                self?.backthreadMessageOutput()
            }

            task.resume()
        }
    }

    func login(_ model: LoginRequest) {

        let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.loginAPI)")!

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

            self?.setToken(respData.token)
            self?.waitingForResponse = false
            self?.actions?.recieveId(for: model.username, token: respData.token)
            self?.actions?.registeredUser(model)
            self?.listenForMessages()
        }

        waitingForResponse = true

        task.resume()
    }

    func listenForMessages() {
        let url = URL(string: "\(APIConstants.webSocketURL)\(APIConstants.chatAPI)")!
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
        let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.fetchUsersAPI)")!
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
