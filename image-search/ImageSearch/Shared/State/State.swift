//
//  State.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

/// Marker protocol to describe abstract State
protocol State {

}

/// Type that can produce state updates with given `State`
protocol StateProducer {
    associatedtype State: ImageSearch.State

    var state: AsyncStream<State> { get }
}

/// Type that can receive state updates with given `State`
protocol StateConsumer: AnyObject {
    associatedtype State: ImageSearch.State
}
