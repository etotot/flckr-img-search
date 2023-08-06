//
//  ImageSearchState.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

enum ImgSearch {
    enum Sections: Hashable {
        case history
        case photos
    }

    enum Items: Hashable {
        case query(String)
        case photo(Photo)
    }

    enum Error: Swift.Error {
        case loadFailed
    }

    struct Context: LoadingListContext {
        let query: String?
        let hasMore: Bool
        let page: Int
    }

    typealias State = LoadingListState<Sections, Items, Context, Error>
}

extension ImgSearch.State {
    func toLoading(query: String) -> Self {
        .loading(
            snapshot: snapshot,
            context: .init(
                query: query,
                hasMore: context.hasMore,
                page: context.page
            )
        )
    }
}
