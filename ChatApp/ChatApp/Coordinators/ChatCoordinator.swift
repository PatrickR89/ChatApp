//
//  ChatCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit
import Factory

/// Coordinator class responsible for navigating UI and functionality within Chat, after login was succesful.
class ChatCoordinator {
    /// Injected dependency from `Factory` containing ``ChatService`` instance
    @Injected (\.chatService) private var chatService
    /// Instance of `UINavigationController` provided by parent coordinator.
    let navController: UINavigationController
    private(set) var activeUsersController: ActiveUsersController?
    private(set) var tabBarController: ChatTabBarController?
    private(set) var conversationsController = ConversationsController()
    private(set) var activeUsersViewController: ActiveUsersViewController?
    private(set) var convViewController: ConversationsViewController?

    init(with navController: UINavigationController) {
        self.navController = navController
    }

    deinit {
        activeUsersController = nil
        tabBarController = nil
        activeUsersViewController = nil
        convViewController = nil
    }

    /// Main method in ``ChatCoordinator`` which creates an instance of and presents
    /// `UITabBarController` and creates instances of it's children
    func start() {

        startActiveUsersViewController()
        startConversationsViewController()

        tabBarController = ChatTabBarController(navController: navController)
        let activeUsersViewController = activeUsersViewController ?? ActiveUsersViewController(
            activeUsersController ?? ActiveUsersController())
        let convViewController = convViewController ?? ConversationsViewController(conversationsController)
        guard let tabBarController = tabBarController else {return}
        tabBarController.setViewControllers([activeUsersViewController, convViewController], animated: true)
        tabBarController.chatDelegate = self

        navController.pushViewController(tabBarController, animated: true)
    }

    /// Method which creates ``activeUsersViewController`` with corresponding
    /// `Controller` generating `UITabBarItem` accordingly
    /// > Method is called in ``start()``
    private func startActiveUsersViewController() {
        activeUsersController = ActiveUsersController()
        activeUsersController?.actions = self
        activeUsersViewController = ActiveUsersViewController(activeUsersController ?? ActiveUsersController())
        activeUsersViewController?.titleDelegate = self
        let tabItemImage = UIImage(systemName: "person.circle")
        let tabBarItem = UITabBarItem(title: "Active Users", image: tabItemImage, tag: 0)

        activeUsersViewController?.tabBarItem = tabBarItem
    }

    /// Method creates ``ConversationsViewController``, providing it with required controller,
    /// and generating required `UITabBarItem`
    /// > Method is called in ``start()``
    private func startConversationsViewController() {
        conversationsController.actions = self

        convViewController = ConversationsViewController(conversationsController)
        convViewController?.titleDelegate = self
        convViewController?.tabBarItem = UITabBarItem(
            title: "Conversations",
            image: UIImage(systemName: "bubble.left"),
            tag: 1)
    }

    /// Method which creates an instance of ``ChatTableViewController``, upon selection of a user or conversation
    /// - Parameters:
    ///   - user: `String` value containing username with who user wishes to start conversation
    ///   - messages: `Array` of ``MessageViewModel`` which loads messages with selected user if they are available.
    private func startChatTableViewController(_ user: String, _ messages: [MessageViewModel]) {
        let chatController = ChatController()
        chatController.openChat(user, messages)
        chatController.actions = conversationsController
        let chatViewController = ChatTableViewController(chatController)
        navController.pushViewController(chatViewController, animated: true)
    }
}

extension ChatCoordinator: ChatTabBarControllerDelegate {
    /// Method connected to "refresh" button in ``ChatTabBarController`` requesting active users from server.
    func chatTabBarDidRequestUsers() {
        activeUsersController?.requestUsers()
    }

    /// Method connected to "logout" button in ``ChatTabBarController``
    /// requesting destruction of instance of ``TokenModel``
    /// > Method is still undeveloped
    func chatTabBarDidRequestLogout() {
        print("logout request")
    }
}

extension ChatCoordinator: ChatTabBarChildDelegate {
    /// Delegate method changing the `title` depending on currently active `UIViewController`
    /// - Parameter title: `String` containing title of currently active `viewController`
    func tabBarChild(didSet title: String) {
        tabBarController?.setTitle(title)
    }
}

extension ChatCoordinator: ActiveUsersControllerActions {
    /// Delegate method which requests presentation of ``ChatTableViewController``
    /// from ``ActiveUsersController`` upon selection in `tableView`
    /// - Parameter user: ``User`` instance of selected user in ``ActiveUsersController``
    func activeUsersControllerDidSelect(user: User) {
        conversationsController.startConversation(with: user.username)
    }
}

extension ChatCoordinator: ConversationControllerActions {
    /// Delegate method which requests presentation of ``ChatTableViewController``
    /// from ``ConversationsViewController`` upon selection of a conversation in `tableView`
    /// - Parameters:
    ///   - user: `String` value containing name of the user from conversation
    ///   - conversation: `Array` of messages already sent between users
    func conversationControllerDidSelect(_ user: String, _ conversation: [MessageViewModel]) {
        startChatTableViewController(user, conversation)
    }
}
