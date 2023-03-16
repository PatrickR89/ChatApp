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

    init(_ navController: UINavigationController, _ chatService: ChatService, _ databaseService: DatabaseService) {
        self.chatService = chatService
        self.databaseService = databaseService
        self.navController = navController
        self.chatService.actions = self
        self.databaseService.userDelegate = self
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

        navController.viewControllers.last?.view.addSubview(serviceNotification)
    }
}

extension MainCoordinator: ChatServiceActions {
    func registeredUser(_ user: LoginRequest) {
        databaseService.saveUser(username: user.username, name: user.name, lastname: user.surname)
    }

    func recieveId(for username: String, token id: String) {
        self.token = id
        databaseService.saveToken(username: username, token: id)
        start()
    }

    func errorOccured(_ error: String) {
        DispatchQueue.main.async {
            self.presentServiceNotification(error)
        }
    }
}

extension MainCoordinator: DatabaseServiceUserDelegate {
    func databaseService(didRecieve token: String) {
        self.token = token
        chatService.setToken(token)
    }
}
