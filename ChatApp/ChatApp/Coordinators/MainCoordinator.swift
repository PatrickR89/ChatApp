//
//  MainCoordinator.swift
//  ChatApp
//
//  Created by Patrick on 06.02.2023..
//

import UIKit
import Combine
import Factory

/// MainCoordinator is a class which is primarily responsible for UI and functionality coordination,
///  as also a network of require delegacies.
class MainCoordinator {

    /// ChatService instance initiated in Factory Container
    @Injected(\.chatService) private var chatService
    /// DatabaseService instance initiated in Factory Container
    @Injected(\.databaseService) private var databaseService
    /// Primary dependency required for communication with server, published via Combine,
    /// in order to report to required classes about every change.
    @Published var token: String? {
        didSet {
            selectViewController()
        }
    }

    let navController: UINavigationController
    var childCoordinator: ChatCoordinator?
    var windowScene: UIWindowScene?
    var notificationWindow: UIWindow?

    init(_ navController: UINavigationController, _ databaseService: DatabaseService) {
        self.navController = navController
        chatService.setDelegacy(controller: .main(self))
        self.databaseService.delegate = self
    }

    /// Main method which starts application, is calles from `SceneDelegate`, just after creating an instance of ``MainCoordinator``.
    /// Method loads user and token from database if they exists.
    func start() {
        databaseService.loadUser()
        databaseService.loadToken()
        selectViewController()
    }

    /// Switch method presenting viewController, depending on token if exists or not
    func selectViewController() {
//        if token == nil {
//            presentLoginScreen()
//        } else {
            presentChatView()
//        }
    }

    /// Method creating a new instance of ``LoginViewController``, pushing it to active ``navController``,
    /// removing previous `ViewControllers` if any exist.
    func presentLoginScreen() {
        if !navController.viewControllers.isEmpty {
            navController.popViewController(animated: true)
        }

        let loginViewController = LoginViewController()
        navController.pushViewController(loginViewController, animated: true)
    }

    /// Method responsible for creating an instance of ``ChatCoordinator``, removing loginViewController if not required any more.
    /// Method also calls child coordinator's `start()` method.
    func presentChatView() {
        if !navController.viewControllers.isEmpty {
            navController.popViewController(animated: true)
        }

        self.childCoordinator = ChatCoordinator(with: navController)
        childCoordinator?.start()
    }

    /// Method which presents information regarding network and server connection state to be visible to user.
    /// - Parameter message: Message as `String` which will be presented to user.
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

    /// Method which adds `UIWindowScene` to ``MainCoordinator`` parameters
    /// - Parameter windowScene: `UIWindowScene` provided by `SceneDelegate`
    func addWindowScene(_ windowScene: UIWindowScene) {
        self.windowScene = windowScene
    }

    /// Method which creates a new window in which Notification will be presented, in order to avoid modifying current UI.
    /// - Parameter frame: `CGRect` value provided for creating new instance of `UIWindow`.
    /// > In this particular case `frame` is created in ``presentServiceNotification(_:)``
    ///
    func createNotificationWindow(in frame: CGRect) {
        notificationWindow = UIWindow(frame: frame)
        notificationWindow?.windowLevel = .alert
        notificationWindow?.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude) - 10
        notificationWindow?.isUserInteractionEnabled = false
        notificationWindow?.isHidden = false
        guard let windowScene else {return}
        notificationWindow?.windowScene = windowScene
    }

    /// Method which destroys notification window after timeout to avoid stacking notification windows,
    /// and remove the overlay of the same over UI.
    func destroyNotificationWindow() {
        notificationWindow = nil
    }
}

extension MainCoordinator: ChatServiceActions {

    /// Method called by ``ChatService`` when response from server is recieved.
    /// - Parameters:
    ///   - username: `String` containing username which is stored as typed in by user
    ///   - id: `String` value containing token generated by server, which is required for further interaction.
    /// >  Method calls ``start()`` in order to change user state.

    func chatService(didRecieve username: String, and id: String) {
        self.token = id
        start()
    }

    /// Method which calls ``presentServiceNotification(_:)`` if an error was recieved either from server or network.
    /// - Parameter error: `String` containing error message
    func chatService(didRecieveError error: String) {
        DispatchQueue.main.async {
            self.presentServiceNotification(error)
        }
    }
}

extension MainCoordinator: DatabaseServiceDelegate {
    /// Method which populates ``ChatService`` with unsent messages when they are loaded from database.
    /// - Parameter messages: `Array` of messages which were saved and not sent.
    /// > Method is delegated in order to avoid circular dependency within `Factory`.
    func databaseService(didRecieve messages: [PendingMessage]) {
        chatService.populatePendingMessages(messages)
    }

    /// Method which sets the ``token`` if user opens app which already recieved the token from server.
    /// - Parameter token: `String` value which contains token generated by server.
    /// > Method is delegated in order to avoid circular dependency within `Factory`.
    func databaseService(didRecieve token: String) {
        self.token = token
        chatService.setToken(token)
    }
}

extension MainCoordinator: ServiceNotificationViewDelegate {
    /// Delegate method from ``ServiceNotificationView`` requesting destruction of ``notificationWindow`` after timeout.
    func notificationViewDidRemoveSelf() {
        destroyNotificationWindow()
    }
}
