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

protocol LoadingListContext {
    var hasMore: Bool { get }
}

enum LoadingListState<
    SectionIdentifier: Hashable,
    ItemIdentifier: Hashable,
    Context: LoadingListContext,
    Error: Swift.Error
> {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    
    case initial(snapshot: SnapshotType, context: Context)
    case loading(snapshot: SnapshotType, context: Context)
    case loaded(snapshot: SnapshotType, context: Context)
    case error(snapshot: SnapshotType, context: Context, error: Error)
    
    // MARK: - Getters
    
    var snapshot: SnapshotType {
        switch self {
        case .initial(let snapshot, _):
            return snapshot
        case .loading(let snapshot, _):
            return snapshot
        case .loaded(let snapshot, _):
            return snapshot
        case .error(let snapshot, _, _):
            return snapshot
        }
    }
    
    var context: Context {
        switch self {
        case .initial(_, let context):
            return context
        case .loading(_, let context):
            return context
        case .loaded(_, let context):
            return context
        case .error(_, let context, _):
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
