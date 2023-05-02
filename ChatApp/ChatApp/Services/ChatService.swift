//
//  ChatService.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import Foundation
import Factory

protocol ChatServiceDelegate: AnyObject {
    func chatService(didRecieve message: RecievedMessage)
    func chatService(didSendMessage id: UUID, to user: String, withSuccess success: Bool)
}

extension ChatServiceDelegate {
    func chatService(didSendMessage id: UUID, to user: String, withSuccess success: Bool) {}
}

protocol ChatServiceUsersDelegate: AnyObject {
    func chatService(didRecieve users: [User])
}

protocol ChatServiceActions: AnyObject {
    func chatService(didRecieve username: String, and token: String)
    func chatService(didRecieveError error: String)
}

protocol ChatServiceResponse: AnyObject {
    func chatService(_ isWaitingForResponse: Bool)
}

/// Class used for network service containing required APIs.
class ChatService: NSObject {

    /// variable containing database service instance provided by Factory.
    @Injected(\.databaseService) private var databaseService
    /// variable containing token value returned from server, which is then also saved in `Realm`database.
    private var token: String?
    /// `URLSessionWebSocketTask` required for aporopriate URL request of messages.
    private var webSocket: URLSessionWebSocketTask?
    private var waitingForResponse = false {
        didSet {
            DispatchQueue.main.async {
                self.responseDelegate?.chatService(self.waitingForResponse)
            }
        }
    }

    /// Variable containing the `Array` of unsent messages due to server or network connection issues.
    private var pendingMessages = [PendingMessage]()

    override init() {
        super.init()
        databaseService.loadPendingMessages()
    }

    weak var delegate: ChatServiceDelegate?
    weak var actions: ChatServiceActions?
    weak var responseDelegate: ChatServiceResponse?
    weak var usersDelegate: ChatServiceUsersDelegate?

    func setToken(_ token: String) {
        self.token = token
    }

    /// Method which sets controllers as delegates, deending on their functionalities.
    /// - Parameter controller: `Enum` value carying instance of the controller themselves.
    func setDelegacy(controller: ChatServiceDelegateType) {
        switch controller {
        case .login(let loginController):
            self.responseDelegate = loginController
        case .main(let mainCoordinator):
            self.actions = mainCoordinator
        case .active(let activeUsersController):
            self.usersDelegate = activeUsersController
        case .conversation(let conversationsController):
            self.delegate = conversationsController
        case .chat(let chatController):
            self.delegate = chatController
        }
    }

    /// Method which sends created message to defined destination via given server API.
    /// - Parameters:
    ///   - message: Instance of ``SentMessage`` containing content and destination.
    ///   - messageId: `UUID` value containing message ID as saved localy.
    /// > Method checks connection availability. In case message was not sent, it is appended to `pendingMessages`.
    ///  Both error and all responses are handled.
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
                self.actions?.chatService(didRecieveError: error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                let pendingMessage = PendingMessage(message: message, id: messageId)
                self.pendingMessages.append(pendingMessage)
                self.backthreadMessageOutput()

                self.delegate?.chatService(didSendMessage: messageId, to: message.chatId, withSuccess: false)
                if response.statusCode >= 400 && response.statusCode < 500 {
                    self.actions?.chatService(didRecieveError: "Error in request")
                } else if response.statusCode >= 500 {
                    self.actions?.chatService(didRecieveError: "Error occured on server")
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

    /// Method with loop which repeatedly tries connection to server, and sends messages if server is reachable.
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

    public func populatePendingMessages(_ messages: [PendingMessage]) {
        self.pendingMessages = messages
    }

    /// Method targeting server API with credentials in order to recieve required token.
    /// - Parameter model: Instance of ``LoginRequest`` containing al required information for succesfull auth.
    func login(_ model: LoginRequest) {

        let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.loginAPI)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(model)
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                self?.waitingForResponse = false
                self?.actions?.chatService(didRecieveError: error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                self?.waitingForResponse = false
                if response.statusCode == 403 || response.statusCode == 401 {
                    self?.actions?.chatService(didRecieveError: "Authentication failed")
                } else if response.statusCode >= 400 && response.statusCode < 500 {
                    self?.actions?.chatService(didRecieveError: "Error in request")
                } else if response.statusCode >= 500 {
                    self?.actions?.chatService(didRecieveError: "Error occured on server")
                }

                return
            }

            guard let data = data else {
                self?.actions?.chatService(didRecieveError: "Error occured while fetching data")
                return
            }

            guard let respData = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                self?.actions?.chatService(didRecieveError: "Error in retrieved data")
                return
            }

            self?.setToken(respData.token)
            self?.waitingForResponse = false
            self?.actions?.chatService(didRecieve: model.username, and: respData.token)
            self?.databaseService.saveToken(username: model.username, token: respData.token)
            self?.databaseService.saveUser(username: model.username, name: model.name, lastname: model.surname)
            self?.listenForMessages()
        }

        waitingForResponse = true

        task.resume()
    }

    /// Recursive web socket method which listens for new messages.
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

    /// Method for storing and presenting recieved message localy. With call on new web socket awaiting for messages.
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

    /// Method wich decodes content from JSON, and sends to responding class via delegate.
    /// - Parameter data: recieved data from server
    func recieveMessageData(_ data: Data) {
        guard let message = try? JSONDecoder().decode(RecievedMessage.self, from: data) else {return}
        DispatchQueue.main.async {
            self.delegate?.chatService(didRecieve: message)
        }
    }

    /// Method for fetching all active users available on server.
    func fetchActiveUsers() {
        let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.fetchUsersAPI)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["mojToken": token ?? ""]
        request.timeoutInterval = 5

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            if let error = error {
                self?.waitingForResponse = false
                self?.actions?.chatService(didRecieveError: error.localizedDescription)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard response.statusCode == 200 else {
                self?.waitingForResponse = false
                if response.statusCode >= 400 && response.statusCode < 500 {
                    self?.actions?.chatService(didRecieveError: "Error in request")
                } else if response.statusCode >= 500 {
                    self?.actions?.chatService(didRecieveError: "Error occured on server")
                }

                return
            }

            guard let data = data else {
                self?.actions?.chatService(didRecieveError: "Error occured while fetching data")
                return
            }

            guard let users = try? JSONDecoder().decode([User].self, from: data) else {
                self?.actions?.chatService(didRecieveError: "Error in retrieved data")
                return
            }

            DispatchQueue.main.async {
                self?.usersDelegate?.chatService(didRecieve: users)
            }
        }

        task.resume()
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
