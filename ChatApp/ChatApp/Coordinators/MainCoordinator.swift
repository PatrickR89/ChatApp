//
//  MainCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine

class MainCoordinator {

    @Published var token: String? = UserDefaults().string(forKey: "CHAT_ID")
    let navController: UINavigationController
    var chatService: ChatService
    var childCoordinator: ChatCoordinator?

    init(_ navController: UINavigationController, _ chatService: ChatService) {
        self.chatService = chatService
        self.navController = navController
        self.chatService.actions = self
    }

    func start() {
//        if token == nil {
//            presentLoginScreen()
//        } else {
            presentChatView()
//        }
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

        self.childCoordinator = ChatCoordinator(with: navController, and: chatService)
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
    func errorOccured(_ error: String) {
        DispatchQueue.main.async {
            self.presentServiceNotification(error)
        }
    }

    func recieveId(_ id: String) {
        self.token = id
        start()
    }
}
