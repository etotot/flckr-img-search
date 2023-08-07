//
//  AppCoordinator.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import UIKit

class AppCoordinator {
    let navigationController: UINavigationController
    var imageSearchViewController: ImageSearchViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor func start() {
        let apiService = URLSessionApiService(baseURL: URL(string: "https://www.flickr.com")!)

        let viewController = ImageSearchViewController()

        navigationController.pushViewController(viewController, animated: false)

        let searchBar = UISearchBar()
        viewController.navigationItem.titleView = searchBar
        viewController.title = "Image Search"
        viewController.showError = { [weak self] in
            self?.showError()
        }

        viewController.viewModel = .init(
            apiService: apiService,
            searchHistoryService: UserDefaultsSearchHistoryService(),
            queryStateProducer: SearchBarStateProducer(searchBar: searchBar)
        )

        self.imageSearchViewController = viewController
    }

    @MainActor private func showError() {
        let alertController = UIAlertController(
            title: "Error",
            message: "Could not load content",
            preferredStyle: .alert
        )

        alertController.addAction(.init(title: "Dismiss", style: .cancel))
        imageSearchViewController?.present(alertController, animated: true)
    }
}
