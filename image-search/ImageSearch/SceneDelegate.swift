//
//  SceneDelegate.swift
//  image-search
//
//  Created by andrey.marshak on 06.08.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var coordinator: AppCoordinator?
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigationController = UINavigationController()
        navigationController.navigationBar.prefersLargeTitles = true

        coordinator = AppCoordinator(navigationController: navigationController)
        coordinator?.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
