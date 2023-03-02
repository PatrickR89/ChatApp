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

        setupTabBarAppearance()
        addTabBarItems()
        setupBackground()

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
    }

    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.selected.titleTextAttributes =
        [NSAttributedString.Key.font: UIFont(name: SupremeFont.extraBold, size: 10)!,
         NSAttributedString.Key.foregroundColor: UIConstants.accentColor]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes =
        [NSAttributedString.Key.font: UIFont(name: SupremeFont.boldItalic, size: 10)!,
         NSAttributedString.Key.foregroundColor: UIConstants.inactiveAccentColor]
        appearance.backgroundColor = .clear
        appearance.stackedLayoutAppearance.selected.iconColor = UIConstants.accentColor
        appearance.stackedLayoutAppearance.normal.iconColor = UIConstants.inactiveAccentColor
        appearance.configureWithTransparentBackground()

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    @objc private func requestUsers() {
        chatDelegate?.chatTabBarDidRequestUsers()
    }

    @objc private func requestLogout() {
        chatDelegate?.chatTabBarDidRequestLogout()
    }

    func setTitle(_ titleText: String) {
        navigationController?.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIConstants.backgroundColorLight,
                                               NSAttributedString.Key.font: UIFont(name: SupremeFont.italic, size: 40)!]
        appearance.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: SupremeFont.italic, size: 20)!,
            NSAttributedString.Key.foregroundColor: UIConstants.backgroundColorLight
        ]
        appearance.configureWithTransparentBackground()

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
                target: self, action: #selector(requestUsers))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
