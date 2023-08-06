//
//  MockStateConsumer.swift
//  ImageSearchTests
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation
@testable import ImageSearch

final class StateConsumerMock<State: ImageSearch.State>: StateConsumer {
    var updateToCallsCount = 0
    var updateToCalled: Bool {
        updateToCallsCount > 0
    }

    var updateToReceivedNewState: State?
    var updateToReceivedInvocations: [State] = []

    // MARK: - update

    func update(to newState: State) {
        updateToCallsCount += 1
        updateToReceivedNewState = newState
        updateToReceivedInvocations.append(newState)
    }
}
