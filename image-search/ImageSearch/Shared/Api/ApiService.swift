//
//  ApiService.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

protocol ApiService: Sendable {
    func call<E: Endpoint>(
        _ endpoint: E
    ) async throws -> E.Success
}
