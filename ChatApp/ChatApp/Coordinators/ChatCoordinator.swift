//
//  ChatCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class ChatCoordinator {
    let navController: UINavigationController
    let chatService: ChatService
    var activeUsersController: ActiveUsersController?
    var activeUsersViewController: ActiveUsersViewController?

    init(with navController: UINavigationController, and service: ChatService) {
        self.navController = navController
        self.chatService = service
    }

    deinit {
        activeUsersController = nil
        activeUsersViewController = nil
    }

    func start() {
        activeUsersController = ActiveUsersController()
        activeUsersController?.delegate = chatService
        chatService.usersDelegate = activeUsersController
        activeUsersViewController = ActiveUsersViewController(activeUsersController ?? ActiveUsersController())
        let convViewController = ConversationsViewController()

        activeUsersViewController?.tabBarItem = UITabBarItem(title: "Active Users", image: UIImage(systemName: "person.circle"), tag: 0)
        convViewController.tabBarItem = UITabBarItem(title: "Conversations", image: UIImage(systemName: "bubble.left"), tag: 1)

        let tabBarController = ChatTabBarController(navController: navController)
        tabBarController.setViewControllers([activeUsersViewController ?? ActiveUsersViewController(activeUsersController ?? ActiveUsersController()), convViewController], animated: true)
        tabBarController.chatDelegate = self

        navController.pushViewController(tabBarController, animated: true)
    }
}

extension ChatCoordinator: ChatTabBarControllerDelegate {
    func chatTabBarDidRequestUsers() {
        activeUsersController?.requestUsers()
    }

    func chatTabBarDidRequestLogout() {
        //
    }
}
