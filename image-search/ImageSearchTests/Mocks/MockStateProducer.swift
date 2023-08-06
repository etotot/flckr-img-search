//
//  MockStateProducer.swift
//  ImageSearchTests
//
//  Created by andrey.marshak on 07.08.2023.
//

import Foundation
@testable import ImageSearch

class MockStreamStateProducer<State: ImageSearch.State>: StateProducer {
    private var continuation: AsyncStream<State>.Continuation?
    var state: AsyncStream<State>

    init(state: AsyncStream<State>) {
        self.state = state
    }
}

class MockStateProducer<State: ImageSearch.State>: StateProducer {
    private var continuation: AsyncStream<State>.Continuation?

    lazy var state: AsyncStream<State> = {
        return .init { continuation in
            self.continuation = continuation
        }
    }()

    func send(state: State) async {
        _ = self.state
        self.continuation?.yield(state)
    }
}

