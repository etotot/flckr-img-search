//
//  SearchBarStateProducer.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import UIKit

extension String: State {}

class SearchBarStateProducer: NSObject, UISearchBarDelegate, StateProducer {
    typealias State = String

    private var _state: String = "" {
        didSet {
            _continuation?.yield(_state)
        }
    }

    private var _continuation: AsyncStream<State>.Continuation?
    lazy var state: AsyncStream<State> = {
        let stream = AsyncStream<State> { continuation in
            _continuation = continuation
        }

        return stream
    }()

    init(searchBar: UISearchBar) {
        super.init()
        searchBar.delegate = self
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        _state = searchText
    }
}
