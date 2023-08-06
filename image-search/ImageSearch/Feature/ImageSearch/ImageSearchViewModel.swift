//
//  ImageSearchViewModel.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation
import AsyncAlgorithms

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

class ImageSearchViewModel: StateProducer, StateConsumer {
    typealias State = ImgSearch.State

    private var _state: ImgSearch.State {
        didSet {
            _continuation?.yield(_state)
        }
    }

    private var _continuation: AsyncStream<ImgSearch.State>.Continuation?

    lazy var state: AsyncStream<ImgSearch.State> = {
        let stream = AsyncStream<ImgSearch.State> { continuation in
            _continuation = continuation
            _continuation?.yield(_state)
        }

        return stream
    }()

    private(set) var apiService: ApiService
    private(set) var searchHistoryService: SearchHistoryService

    private var queryStateProducer: any StateProducer
    private var queryObservation: Task<Void, Error>?

    init<S: StateProducer>(
        apiService: ApiService,
        searchHistoryService: SearchHistoryService,
        queryStateProducer: S
    ) where S.State == String {
        self.apiService = apiService
        self.searchHistoryService = searchHistoryService

        var snapshot = ImgSearch.State.SnapshotType()
        snapshot.appendSections([.history, .photos])
        snapshot.appendItems(searchHistoryService.queries.map { .query($0) }, toSection: .history)

        self._state = .initial(snapshot: snapshot, context: .init(query: nil, hasMore: true, page: 0))

        self.queryStateProducer = queryStateProducer
        self.queryObservation = Task { [unowned self] in
            for try await query in queryStateProducer.state.debounce(for: .seconds(0.5)) {
                await self.search(query: query)
            }
        }
    }

    deinit {
        queryObservation?.cancel()
        queryObservation = nil
    }

    // MARK: - Loading

    func search(query: String) async {
        guard !query.isEmpty else {
            return
        }

        await load(query: query)
    }

    func loadNext() async {
        guard _state.context.hasMore, let query = _state.context.query else {
            return
        }

        await load(query: query, page: _state.context.page + 1)
    }

    private var loadTask: Task<Void, Error>?

    private func load(query: String, page: Int = 0) async {
        guard !query.isEmpty else {
            return
        }

        if case let ImgSearch.State.loading(_, context) = _state, context.query == query, context.page == page {
            return
        }

        loadTask?.cancel()

        var snapshot = _state.snapshot

        if page == 0 {
            snapshot = .init()
            snapshot.appendSections([.history, .photos])
        }

        let state = _state.toLoading(query: query, snapshot: snapshot)
        self._state = state

        loadTask = Task {
            do {
                try Task.checkCancellation()

                let result = try await apiService.call(
                    FlickrEndpoint<Search>.search(query: query, page: page)
                )

                try Task.checkCancellation()

                var snapshot = _state.snapshot
                snapshot.appendItems(result.photos.photo.map { ImgSearch.Items.photo($0) })

                searchHistoryService.insert(query: query)

                _state = state.toLoaded(
                    snapshot: snapshot,
                    context: .init(
                        query: query,
                        hasMore: result.photos.page != result.photos.pages,
                        page: result.photos.page
                    )
                )
            } catch let error {
                if error is CancellationError { return }

                _state = state.toError(error: .loadFailed)
            }
        }
    }
}
