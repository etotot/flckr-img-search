//
//  State.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

/// Marker protocol to describe abstract State
protocol State { }

/// Type that can produce state updates with given `State`
protocol StateProducer {
    associatedtype State: ImageSearch.State
    
    /// Current producer `State`
    var state: State { get }
    
    /// Subscribers `consumer` to updates from given `producer`
    func add<C: StateConsumer>(consumer: C) where C.State == State
    
    /// Unsubscribers `consumer` to updates from given `producer`
    func remove<C: StateConsumer>(consumer: C)  where C.State == State
}

/// Type that can receive state updates with given `State`
protocol StateConsumer {
    associatedtype State: ImageSearch.State
    
    /// Handle update to new state
    func update(to newState: State) async
}
