//
//  MockSearchHistoryService.swift
//  ImageSearchTests
//
//  Created by andrey.marshak on 07.08.2023.
//

import Foundation
@testable import ImageSearch

final class SearchHistoryServiceMock: SearchHistoryService {
    var queries: [String]

    init(queries: [String] = []) {
        self.queries = queries
    }

    // MARK: - insert

    var insertQueryCallsCount = 0
    var insertQueryCalled: Bool {
        insertQueryCallsCount > 0
    }
    var insertQueryReceivedQuery: String?
    var insertQueryReceivedInvocations: [String] = []
    var insertQueryClosure: ((String) -> Void)?

    func insert(query: String) {
        insertQueryCallsCount += 1
        insertQueryReceivedQuery = query
        insertQueryReceivedInvocations.append(query)
        insertQueryClosure?(query)
    }
}
