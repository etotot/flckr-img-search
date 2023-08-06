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

class ImageSearchViewModel: StateProducer {
    private(set) var state: ImgSearch.State {
        didSet {
            guard let consumer else {
                return
            }

            Task {
                await consumer.update(to: state)
            }
        }
    }

    private weak var consumer: AnyStateConsumer<ImgSearch.State>? {
        didSet {
            guard let consumer else {
                return
            }

            Task {
                await consumer.update(to: state)
            }
        }
    }

    private(set) var apiService: ApiService

    init(apiService: ApiService) {
        self.apiService = apiService

        var snapshot = ImgSearch.State.SnapshotType()
        snapshot.appendSections([.history, .photos])

        state = .initial(snapshot: snapshot, context: .init(query: nil, hasMore: true, page: 0))
    }

    // MARK: - Loading

    func search(query: String) async {
        guard !query.isEmpty else {
            return
        }

        await load(query: query)
    }

    func loadNext() async {
        guard state.context.hasMore, let query = state.context.query else {
            return
        }

        await load(query: query, page: state.context.page + 1)
    }

    private func load(query: String, page: Int = 0) async {
        guard !query.isEmpty else {
            return
        }

        let state = state.toLoading(query: query)

        do {
            let result = try await apiService.call(
                FlickrEndpoint<Search>.search(query: query, page: page)
            )

            var snapshot = State.SnapshotType()
            snapshot.appendSections([.photos])
            snapshot.appendItems(result.photos.photo.map { ImgSearch.Items.photo($0) })

            self.state = state.toLoaded(
                snapshot: snapshot,
                context: .init(
                    query: query,
                    hasMore: result.photos.page != result.photos.pages,
                    page: result.photos.page
                )
            )
        } catch {
            self.state = state.toError(error: .loadFailed)
        }
    }

    // MARK: - StateProducer

    func add<C>(consumer: C) where C: StateConsumer, ImgSearch.State == C.State {
        self.consumer = consumer.toAnyStateConsumer()
    }

    func remove<C>(consumer _: C) where C: StateConsumer, ImgSearch.State == C.State {
        consumer = nil
    }
}
