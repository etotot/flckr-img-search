//
//  State.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

/// Marker protocol to describe abstract State
protocol State: Sendable {

}

/// Type that can produce state updates with given `State`
protocol StateProducer: Sendable {
    associatedtype State: ImageSearch.State & Sendable
    associatedtype `Sequence`: AsyncSequence where Sequence.Element == State

    var state: Sequence { get }
}

/// Type that can receive state updates with given `State`
protocol StateConsumer: AnyObject {
    associatedtype State: ImageSearch.State
}
