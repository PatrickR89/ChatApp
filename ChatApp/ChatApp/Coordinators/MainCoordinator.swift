//
//  MainCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine

class MainCoordinator {

    @Published var token: String? {
        didSet {
            selectViewController()
        }
    }

    let navController: UINavigationController
    var chatService: ChatService
    let databaseService: DatabaseService
    var childCoordinator: ChatCoordinator?
    var windowScene: UIWindowScene?
    var notificationWindow: UIWindow?

    init(_ navController: UINavigationController, _ chatService: ChatService, _ databaseService: DatabaseService) {
        self.chatService = chatService
        self.databaseService = databaseService
        self.navController = navController
        self.chatService.actions = self
        self.databaseService.delegate = self
    }

    func start() {
        databaseService.loadUser()
        databaseService.loadToken()
        selectViewController()
    }

    func selectViewController() {
        if token == nil {
            presentLoginScreen()
        } else {
            presentChatView()
        }
    }

    func presentLoginScreen() {
        if !navController.viewControllers.isEmpty {
            navController.popViewController(animated: true)
        }

        let loginViewController = LoginViewController(with: chatService)
        navController.pushViewController(loginViewController, animated: true)
    }

    func presentChatView() {
        if !navController.viewControllers.isEmpty {
            navController.popViewController(animated: true)
        }

        self.childCoordinator = ChatCoordinator(with: navController, chatService, databaseService)
        childCoordinator?.start()
    }

    func presentServiceNotification(_ message: String) {

        var yPosition = navController.view.frame.height / 2

        if let height = navController.viewControllers.last?.view.frame.height {
            yPosition -= height / 2
        }

        let frame = CGRect(
            x: 0,
            y: yPosition,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height / 2)

        let serviceNotification = ServiceNotificationView(frame: frame, message: message)
        serviceNotification.delegate = self
        createNotificationWindow(in: frame)
        notificationWindow?.addSubview(serviceNotification)
    }

    func addWindowScene(_ windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    func createNotificationWindow(in frame: CGRect) {
        notificationWindow = UIWindow(frame: frame)
        notificationWindow?.windowLevel = .alert
        notificationWindow?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude) - 10
        notificationWindow?.isUserInteractionEnabled = false
        notificationWindow?.isHidden = false
        guard let windowScene else {return}
        notificationWindow?.windowScene = windowScene
    }

    func destroyNotificationWindow() {
        notificationWindow = nil
    }
}

// MARK: chatService <-> databaseService intersection

extension MainCoordinator: ChatServiceActions {
    func chatServiceDidRequestPendingMessages() {
        databaseService.loadPendingMessages()
    }

    func chatService(didRegister user: LoginRequest) {
        databaseService.saveUser(username: user.username, name: user.name, lastname: user.surname)
    }

    func chatService(didRecieve username: String, and id: String) {
        self.token = id
        databaseService.saveToken(username: username, token: id)
        start()
    }

    func chatService(didRecieveError error: String) {
        DispatchQueue.main.async {
            self.presentServiceNotification(error)
        }
    }
}

extension MainCoordinator: DatabaseServiceDelegate {
    func databaseService(didLoadMessages messages: [PendingMessage]) {
        chatService.populatePendingMessages(messages)
    }

    func databaseService(didRecieve token: String) {
        self.token = token
        chatService.setToken(token)
    }
}

extension MainCoordinator: ServiceNotificationViewDelegate {
    func notificationViewDidRemoveSelf() {
        destroyNotificationWindow()
    }
}
