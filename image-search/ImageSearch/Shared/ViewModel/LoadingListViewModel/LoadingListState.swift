//
//  LoadingListState.swift
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

protocol LoadingListContext: Sendable {
    var hasMore: Bool { get }
}

enum LoadingListState<
    SectionIdentifier: Hashable & Sendable,
    ItemIdentifier: Hashable & Sendable,
    Context: LoadingListContext,
    Error: Swift.Error
>: State {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>

    case initial(snapshot: SnapshotType, context: Context)
    case loading(snapshot: SnapshotType, context: Context)
    case loaded(snapshot: SnapshotType, context: Context)
    case error(snapshot: SnapshotType, context: Context, error: Error)

    // MARK: - Getters

    var snapshot: SnapshotType {
        switch self {
        case let .initial(snapshot, _):
            return snapshot
        case let .loading(snapshot, _):
            return snapshot
        case let .loaded(snapshot, _):
            return snapshot
        case let .error(snapshot, _, _):
            return snapshot
        }
    }

    var context: Context {
        switch self {
        case let .initial(_, context):
            return context
        case let .loading(_, context):
            return context
        case let .loaded(_, context):
            return context
        case let .error(_, context, _):
            return context
        }
    }

    // MARK: - State Transitions

    func reset(context: Context) -> Self {
        reset(snapshot: .init(), context: context)
    }

    func reset(snapshot: SnapshotType, context: Context) -> Self {
        .initial(snapshot: snapshot, context: context)
    }

    func toLoading(context: Context) -> Self {
        .loading(snapshot: snapshot, context: context)
    }

    func toLoading(snapshot: SnapshotType, context: Context) -> Self {
        .loading(snapshot: snapshot, context: context)
    }

    func toLoaded(snapshot: SnapshotType, context: Context) -> Self {
        .loaded(snapshot: snapshot, context: context)
    }

    func toError(error: Error) -> Self {
        .error(snapshot: snapshot, context: context, error: error)
    }
}
