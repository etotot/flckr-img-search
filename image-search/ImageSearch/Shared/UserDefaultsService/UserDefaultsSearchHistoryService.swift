//
//  UserDefaultsSearchHistoryService.swift
//  ImageSearch
//
//  Created by andrey.marshak on 07.08.2023.
//

import Foundation

protocol SearchHistoryService: Sendable {
    var queries: [String] { get }
    func insert(query: String)
}

final class UserDefaultsSearchHistoryService: SearchHistoryService {
    private static let key = "SearchHistory"

    private let defaults = UserDefaults()
    private let limit: Int

    private(set) var queries: [String] = []

    init(limit: Int = 20) {
        self.limit = limit
        load()
    }

    func insert(query: String) {
        var queries = queries

        if let index = queries.firstIndex(of: query) {
            queries.remove(at: index)
        }

        queries.insert(query, at: 0)

        while queries.count > limit {
            _ = queries.popLast()
        }

        self.queries = queries
        save()
    }

    private func load() {
        guard let queries = defaults.array(forKey: UserDefaultsSearchHistoryService.key) as? [String] else {
            return
        }

        self.queries = queries
    }

    private func save() {
        defaults.set(queries, forKey: UserDefaultsSearchHistoryService.key)
    }
}
