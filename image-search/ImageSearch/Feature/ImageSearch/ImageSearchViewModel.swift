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

actor StateBox<S: State> {
    private(set) var _state: S { // swiftlint:disable:this identifier_name
        didSet {
            continuation?.yield(_state)
        }
    }

    private var continuation: AsyncStream<S>.Continuation? {
        didSet {
            continuation?.yield(_state)
        }
    }

    lazy var state: AsyncStream<S> = {
        return .init { continuation in
            self.continuation = continuation
        }
    }()

    init(state: S) {
        self._state = state
    }

    func produce(_ state: S) {
        self._state = state
    }
}

final class ImageSearchViewModel: /*StateProducer,*/ StateConsumer, Sendable {
    typealias State = ImgSearch.State

    private let stateBox: StateBox<State>

    var state: AsyncStream<ImgSearch.State> {
        get async {
            return await stateBox.state
        }
    }

    private let apiService: ApiService
    private let searchHistoryService: SearchHistoryService

    private let queryStateProducer: any StateProducer
    private var queryObservation: Task<Void, Error>?

    init<S: StateProducer>(
        apiService: ApiService,
        searchHistoryService: SearchHistoryService,
        queryStateProducer: S
    ) where S.State == String, S.Sequence: Sendable {
        self.apiService = apiService
        self.searchHistoryService = searchHistoryService

        var snapshot = ImgSearch.State.SnapshotType()
        snapshot.appendSections([.history, .photos])
        snapshot.appendItems(searchHistoryService.queries.map { .query($0) }, toSection: .history)

        self.stateBox = .init(state: .initial(snapshot: snapshot, context: .init(query: nil, hasMore: true, page: 0)))

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
        let state = await stateBox._state

        guard state.context.hasMore, let query = state.context.query else {
            return
        }

        await load(query: query, page: state.context.page + 1)
    }

    private var loadTask: Task<Void, Error>?

    private func load(query: String, page: Int = 0) async {
        guard !query.isEmpty else {
            return
        }

        let state = await stateBox._state

        if case let ImgSearch.State.loading(_, context) = state, context.query == query, context.page == page {
            return
        }

        loadTask?.cancel()

        var snapshot = state.snapshot

        if page == 0 {
            snapshot = .init()
            snapshot.appendSections([.history, .photos])
        }

        await stateBox.produce(state.toLoading(query: query, snapshot: snapshot))

        loadTask = Task {
            do {
                try Task.checkCancellation()

                let result = try await apiService.call(
                    FlickrEndpoint<Search>.search(query: query, page: page)
                )

                try Task.checkCancellation()

                let state = await stateBox._state

                var snapshot = state.snapshot
                snapshot.appendItems(result.photos.photo.map { ImgSearch.Items.photo($0) })

                searchHistoryService.insert(query: query)
                await stateBox.produce(
                    state.toLoaded(
                                    snapshot: snapshot,
                                    context: .init(
                                        query: query,
                                        hasMore: result.photos.page != result.photos.pages,
                                        page: result.photos.page
                                    )
                )
                    )
            } catch let error {
                if error is CancellationError { return }

                let state = await stateBox._state
                await stateBox.produce(state.toError(error: .loadFailed))
            }
        }
    }
}
