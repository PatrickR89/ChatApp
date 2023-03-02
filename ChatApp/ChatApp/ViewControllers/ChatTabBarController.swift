//
//  ChatTabBarController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

protocol ChatTabBarControllerDelegate: AnyObject {
    func chatTabBarDidRequestUsers()
    func chatTabBarDidRequestLogout()
}

class ChatTabBarController: UITabBarController {

    let navController: UINavigationController
    weak var chatDelegate: ChatTabBarControllerDelegate?

    init(navController: UINavigationController) {
        self.navController = navController

        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        addTabBarItems()

    }

    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIConstants.backgroundColorDark.cgColor, UIConstants.backgroundColorLight.cgColor]
        gradient.frame = view.bounds
        gradient.startPoint = .init(x: 0.5, y: 0.5)
        gradient.endPoint = .init(x: 0, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func addTabBarItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "power"),
            style: .plain,
            target: self,
            action: #selector(requestLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.triangle.2.circlepath"),
            style: .plain,
            target: self,
            action: #selector(requestUsers))

        tabBar.tintColor = UIConstants.accentColor
        tabBar.unselectedItemTintColor = UIConstants.inactiveAccentColor
    }

    @objc private func requestUsers() {
        chatDelegate?.chatTabBarDidRequestUsers()
    }

    @objc private func requestLogout() {
        chatDelegate?.chatTabBarDidRequestLogout()
    }

    func setTitle(_ titleText: String) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIConstants.backgroundColorLight]

        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = UIConstants.accentColor
        title = titleText

    }
}

extension ChatTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ActiveUsersViewController {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "arrow.triangle.2.circlepath"),
                style: .plain,
                target: nil, action: #selector(requestUsers))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
