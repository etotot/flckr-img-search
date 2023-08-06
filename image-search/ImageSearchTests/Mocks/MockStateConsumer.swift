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

    private var task: Task<Void, Never>?

    init<S: StateProducer>(_ stateProducer: S) where S.State == State {
        task = Task {
            for await state in stateProducer.state {
                updateToCallsCount += 1
                updateToReceivedNewState = state
                updateToReceivedInvocations.append(state)
            }
        }
    }
}
