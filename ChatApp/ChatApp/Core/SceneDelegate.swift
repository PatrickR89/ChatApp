//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Patrick on 14.01.2023..
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {

            guard let windowScene: UIWindowScene = (scene as? UIWindowScene) else {return}

            let navigationController = UINavigationController()
            mainCoordinator = MainCoordinator(navigationController, ChatService())
            mainCoordinator?.start()
            window = UIWindow(frame: windowScene.coordinateSpace.bounds)
            window?.windowScene = windowScene
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
}
