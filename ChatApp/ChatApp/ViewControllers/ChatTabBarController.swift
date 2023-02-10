//
//  ChatTabBarController.swift
//  ChatApp
//
//  Created by Patrick on 10.02.2023..
//

import UIKit

class ChatTabBarController: UITabBarController {

    let navController: UINavigationController

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

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "power"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"), style: .plain, target: nil, action: nil)
    }
}

extension ChatTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController is ActiveUsersViewController {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.2.circlepath"), style: .plain, target: nil, action: nil)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}