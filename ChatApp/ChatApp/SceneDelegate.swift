//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene: UIWindowScene = (scene as? UIWindowScene) else {return}

        let navigationController = UINavigationController()
        let mainViewController = ViewController()

        navigationController.viewControllers = [mainViewController]

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

