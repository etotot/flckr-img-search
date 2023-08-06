//
//  ImageSearchViewController.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import UIKit

class ImageSearchViewController: UIViewController, UICollectionViewDelegate, StateConsumer {
    typealias State = ImgSearch.State

    lazy var layout: UICollectionViewCompositionalLayout = {
        return .init { [unowned self] sectionIndex, layoutEnvironment in
            let snapshot = self.dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[sectionIndex]

            switch section {
            case .history:
                return self.makeSearchHistorySection(layoutEnvironment: layoutEnvironment)
            case .photos:
                return self.makePhotoSection()
            }
        }
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.keyboardDismissMode = .onDrag
        return collectionView
    }()

    lazy var dataSource: UICollectionViewDiffableDataSource<ImgSearch.Sections, ImgSearch.Items> = {
        let historyCellRegistration = UICollectionView.CellRegistration<
            UICollectionViewListCell,
            String
        > { cell, _, item in
            var configuration = cell.searchTermConfiguration()
            configuration.text = item
            cell.contentConfiguration = configuration
        }

        let photoCellRegistration: UICollectionView.CellRegistration<
            PhotoCollectionViewCell,
            Photo
        > = .init { cell, _, item in
            cell.imageView.url = item.url
        }

        let dataSource = UICollectionViewDiffableDataSource<
            ImgSearch.Sections,
            ImgSearch.Items
        >(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .query(let query):
                return collectionView.dequeueConfiguredReusableCell(
                    using: historyCellRegistration,
                    for: indexPath,
                    item: query
                )
            case .photo(let photo):
                return collectionView.dequeueConfiguredReusableCell(
                    using: photoCellRegistration,
                    for: indexPath,
                    item: photo
                )
            }
        }

        return dataSource
    }()

    private var observation: Task<Void, Never>?
    var viewModel: ImageSearchViewModel?

    override func loadView() {
        self.view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = dataSource

        guard let viewModel = viewModel else {
            return
        }

        observation = Task { [stateStream = viewModel.state, weak self] in
            for await state in stateStream {
                await self?.onStateChanged(to: state)
            }
        }
    }

    // MARK: - State

    func onStateChanged(to newState: State) async {
        await MainActor.run {
            let snapshot = newState.snapshot
            dataSource.apply(snapshot)

            switch newState {
            case.loading:
                break
            default:
                if let searchBar = navigationItem.titleView as? UISearchBar {
                    searchBar.text = newState.context.query
                }
            }
        }
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {

    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    // MARK: - Layout Helpers

    private func makeSearchHistorySection(
        layoutEnvironment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.showsSeparators = false

        return .list(using: configuration, layoutEnvironment: layoutEnvironment)
    }

    private func makePhotoSection() -> NSCollectionLayoutSection {
        let photoItem = NSCollectionLayoutItem(layoutSize: .init(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        ))

        let photoGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.5)
            ),
            subitems: [photoItem, photoItem]
        )

        return NSCollectionLayoutSection(group: photoGroup)
    }
}

extension UICollectionViewListCell {
    func searchTermConfiguration() -> UIListContentConfiguration {
        var configuration = self.defaultContentConfiguration()
        configuration.textProperties.font = .preferredFont(forTextStyle: .body)

        return configuration
    }
}
