//
//  MockStateConsumer.swift
//  ImageSearchTests
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation
@testable import ImageSearch

final class StateConsumerSpy<State: ImageSearch.State> {
    var updateToCallsCount = 0
    var updateToCalled: Bool {
        updateToCallsCount > 0
    }

    var updateToReceivedNewState: State?
    var updateToReceivedInvocations: [State] = []

    func consume(state: State) {
        updateToCallsCount += 1
        updateToReceivedNewState = state
        updateToReceivedInvocations.append(state)
    }
}
