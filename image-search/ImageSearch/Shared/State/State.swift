//
//  State.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

/// Marker protocol to describe abstract State
protocol State {
//    static func initial() -> Self
}

/// Type that can produce state updates with given `State`
protocol StateProducer {
    associatedtype State: ImageSearch.State

    /// Current producer `State`
    var state: State { get }

    /// Subscribers `consumer` to updates from given `producer`
    func add<C: StateConsumer>(consumer: C) async where C.State == State

    /// Unsubscribers `consumer` to updates from given `producer`
    func remove<C: StateConsumer>(consumer: C) async where C.State == State
}

/// Type that can receive state updates with given `State`
protocol StateConsumer: AnyObject {
    associatedtype State: ImageSearch.State

    /// Handle update to new state
    func update(to newState: State) async
}

extension StateConsumer {
    func toAnyStateConsumer() -> AnyStateConsumer<State> {
        .init(consumer: self)
    }
}

class AnyStateConsumer<State: ImageSearch.State>: StateConsumer {
    let wrappedUpdate: (State) async -> Void

    init<
        StateConsumer: ImageSearch.StateConsumer
    >(consumer: StateConsumer) where StateConsumer.State == State {
        wrappedUpdate = { [weak consumer] newState in
            await consumer?.update(to: newState)
        }
    }

    func update(to newState: State) async {
        await wrappedUpdate(newState)
    }
}
