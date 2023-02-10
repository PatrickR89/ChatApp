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

    init(with navController: UINavigationController, and service: ChatService) {
        self.navController = navController
        self.chatService = service
    }

    func start() {
        let activeViewController = ActiveUsersViewController()
        let convViewController = ConversationsViewController()

        activeViewController.tabBarItem = UITabBarItem(title: "Active Users", image: UIImage(systemName: "person.circle"), tag: 0)
        convViewController.tabBarItem = UITabBarItem(title: "Conversations", image: UIImage(systemName: "bubble.left"), tag: 1)

        let tabBarController = ChatTabBarController(navController: navController)
        tabBarController.setViewControllers([activeViewController, convViewController], animated: true)

        navController.pushViewController(tabBarController, animated: true)
    }
}
