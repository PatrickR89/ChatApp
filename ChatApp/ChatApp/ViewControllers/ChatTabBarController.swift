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
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "power"), style: .plain, target: self, action: #selector(requestLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"), style: .plain, target: self, action: #selector(requestUsers))
    }

    @objc private func requestUsers() {
        chatDelegate?.chatTabBarDidRequestUsers()
    }

    @objc private func requestLogout() {
        chatDelegate?.chatTabBarDidRequestLogout()
    }

    func setTitle(_ titleText: String) {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        title = titleText
    }
}

extension ChatTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ActiveUsersViewController {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"), style: .plain, target: nil, action: #selector(requestUsers))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}
