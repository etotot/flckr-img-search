//
//  MockApiService.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation
@testable import ImageSearch

final class ApiServiceMock: ApiService {
    // MARK: - call<E: Endpoint>

    var callThrowableError: Error?
    var callCallsCount = 0
    var callCalled: Bool {
        callCallsCount > 0
    }

    var callReceivedEndpoint: (any Endpoint)?
    var callReceivedInvocations: [any Endpoint] = []

    enum Response {
        case data(Data)
        case error(Error)
    }

    var responses: [String: Response]

    init(responses: [String: Response]) {
        self.responses = responses
    }

    func call<E: Endpoint>(_ endpoint: E) async throws -> E.Success {
        if let error = callThrowableError {
            throw error
        }

        callCallsCount += 1
        callReceivedEndpoint = endpoint
        callReceivedInvocations.append(endpoint)

        guard let response = responses[endpoint.path] else {
            throw URLSessionApiService.Error.invalidRequest(endpoint)
        }

        switch response {
        case let .data(data):
            return try JSONDecoder().decode(E.Success.self, from: data)
        case let .error(error):
            throw error
        }
    }
}
