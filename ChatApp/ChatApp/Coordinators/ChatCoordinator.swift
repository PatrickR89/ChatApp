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
    var tabBarController: ChatTabBarController?
    var conversationsController: ConversationsController?

    init(with navController: UINavigationController, and service: ChatService) {
        self.navController = navController
        self.chatService = service
    }

    deinit {
        activeUsersController = nil
        tabBarController = nil
        conversationsController = nil
    }

    func start() {
        let activeUsersViewController = startActiveUsersViewController()
        let convViewController = startConversationsViewController()

        tabBarController = ChatTabBarController(navController: navController)

        guard let tabBarController = tabBarController else {return}
        tabBarController.setViewControllers([activeUsersViewController, convViewController], animated: true)
        tabBarController.chatDelegate = self

        navController.pushViewController(tabBarController, animated: true)
    }

    private func startActiveUsersViewController() -> ActiveUsersViewController {
        activeUsersController = ActiveUsersController()
        activeUsersController?.delegate = chatService
        activeUsersController?.actions = self
        chatService.usersDelegate = activeUsersController
        let activeUsersViewController = ActiveUsersViewController(activeUsersController ?? ActiveUsersController())
        activeUsersViewController.titleDelegate = self
        activeUsersViewController.tabBarItem = UITabBarItem(title: "Active Users", image: UIImage(systemName: "person.circle"), tag: 0)
        return activeUsersViewController
    }

    private func startConversationsViewController() -> ConversationsViewController {
        conversationsController = ConversationsController()
        let convViewController = ConversationsViewController(conversationsController ?? ConversationsController())
        convViewController.titleDelegate = self
        convViewController.tabBarItem = UITabBarItem(title: "Conversations", image: UIImage(systemName: "bubble.left"), tag: 1)
        return convViewController
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

extension ChatCoordinator: ChatTabBarChildDelegate {
    func tabBarChild(didSet title: String) {
        tabBarController?.setTitle(title)
    }
}

extension ChatCoordinator: ActiveUsersControllerActions {
    func activeUsersControllerDidSelect(user: User) {
        let chatViewController = ChatTableViewController(ChatController(user.username, []))
        navController.pushViewController(chatViewController, animated: true)
    }
}
