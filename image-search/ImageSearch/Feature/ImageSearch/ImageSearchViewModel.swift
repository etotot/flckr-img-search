//
//  ImageSearchViewModel.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

class ImageSearchViewModel: StateProducer, StateConsumer {
    private var _state: ImgSearch.State {
        didSet {
            _continuation?.yield(_state)
        }
    }

    private var _continuation: AsyncStream<ImgSearch.State>.Continuation?

    lazy var state: AsyncStream<ImgSearch.State> = {
        let stream = AsyncStream<ImgSearch.State> { continuation in
            _continuation = continuation
        }

        return stream
    }()

    private(set) var apiService: ApiService

    private var queryStateProducer: any StateProducer
    private var queryObservation: Task<Void, Never>?

    init<S: StateProducer>(apiService: ApiService, queryStateProducer: S) where S.State == String {
        self.apiService = apiService

        var snapshot = ImgSearch.State.SnapshotType()
        snapshot.appendSections([.history, .photos])

        _state = .initial(snapshot: snapshot, context: .init(query: nil, hasMore: true, page: 0))

        self.queryStateProducer = queryStateProducer
        queryObservation = Task { [unowned self] in
            for await query in queryStateProducer.state {
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

    private func load(query: String, page: Int = 0) async {
        guard !query.isEmpty else {
            return
        }

        let state = _state.toLoading(query: query)

        do {
            let result = try await apiService.call(
                FlickrEndpoint<Search>.search(query: query, page: page)
            )

            var snapshot = State.SnapshotType()
            snapshot.appendSections([.photos])
            snapshot.appendItems(result.photos.photo.map { ImgSearch.Items.photo($0) })

            _state = state.toLoaded(
                snapshot: snapshot,
                context: .init(
                    query: query,
                    hasMore: result.photos.page != result.photos.pages,
                    page: result.photos.page
                )
            )
        } catch {
            _state = state.toError(error: .loadFailed)
        }
    }
}
