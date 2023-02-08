//
//  MainCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit

class MainCoordinator {
    
    var token: String? = UserDefaults().string(forKey: "CHAT_ID")
    let navController: UINavigationController
    let chatService = ChatService()

    init(navController: UINavigationController) {
        self.navController = navController
        chatService.loginDelegate = self
    }

    func start() {
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
        navController.pushViewController(ChatTableViewController(), animated: true)
    }

}

extension MainCoordinator: ChatServiceLogin {
    func errorOccured(_ error: String) {

        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        navController.visibleViewController?.present(alertController, animated: true)
    }

    func recieveId(_ id: String) {
        self.token = id
        start()
    }
}
