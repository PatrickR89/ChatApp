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
    private(set) var activeUsersController: ActiveUsersController?
    private(set) var tabBarController: ChatTabBarController?
    private(set) var conversationsController: ConversationsController?
    // for test purposes
    private(set) var activeUsersViewController: ActiveUsersViewController?
    private(set) var convViewController: ConversationsViewController?

    init(with navController: UINavigationController, and service: ChatService) {
        self.navController = navController
        self.chatService = service
    }

    deinit {
        activeUsersController = nil
        tabBarController = nil
        conversationsController = nil
        activeUsersViewController = nil
        convViewController = nil
    }

    func start() {

        startActiveUsersViewController()
        startConversationsViewController()

        tabBarController = ChatTabBarController(navController: navController)
        let activeUsersViewController = activeUsersViewController ?? ActiveUsersViewController(activeUsersController ?? ActiveUsersController())
        let convViewController = convViewController ?? ConversationsViewController(conversationsController ?? ConversationsController())

        guard let tabBarController = tabBarController else {return}
        tabBarController.setViewControllers([activeUsersViewController, convViewController], animated: true)
        tabBarController.chatDelegate = self

        navController.pushViewController(tabBarController, animated: true)
    }

    private func startActiveUsersViewController() {
        activeUsersController = ActiveUsersController()
        activeUsersController?.delegate = chatService
        activeUsersController?.actions = self
        chatService.usersDelegate = activeUsersController
        activeUsersViewController = ActiveUsersViewController(activeUsersController ?? ActiveUsersController())
        activeUsersViewController?.titleDelegate = self
        activeUsersViewController?.tabBarItem = UITabBarItem(title: "Active Users", image: UIImage(systemName: "person.circle"), tag: 0)
    }

    private func startConversationsViewController() {
        conversationsController = ConversationsController()
        conversationsController?.actions = self
        chatService.delegate = conversationsController

        convViewController = ConversationsViewController(conversationsController ?? ConversationsController())
        convViewController?.titleDelegate = self
        convViewController?.tabBarItem = UITabBarItem(title: "Conversations", image: UIImage(systemName: "bubble.left"), tag: 1)
    }

    private func startChatTableViewController(_ user: String, _ messages: [MessageViewModel]) {
        let chatController = ChatController()
        chatController.openChat(user, messages)
        chatController.actions = conversationsController
        let chatViewController = ChatTableViewController(chatController)
        navController.pushViewController(chatViewController, animated: true)
    }
}

extension ChatCoordinator: ChatTabBarControllerDelegate {
    func chatTabBarDidRequestUsers() {
        activeUsersController?.requestUsers()
    }

    func chatTabBarDidRequestLogout() {
        print("logout request")
    }
}

extension ChatCoordinator: ChatTabBarChildDelegate {
    func tabBarChild(didSet title: String) {
        tabBarController?.setTitle(title)
    }
}

extension ChatCoordinator: ActiveUsersControllerActions {
    func activeUsersControllerDidSelect(user: User) {
        startChatTableViewController(user.username, [])
    }
}

extension ChatCoordinator: ConversationControllerActions {
    func conversationControllerDidSelect(_ user: String, _ conversation: [MessageViewModel]) {
        startChatTableViewController(user, conversation)
    }
}
