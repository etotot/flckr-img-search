//
//  URLSessionApiService.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

class URLSessionApiService: ApiService {
    enum Error: Swift.Error {
        case invalidRequest(any Endpoint)
        case unexpectedResponseType
        case decodingError(Swift.DecodingError)
    }
    
    private let session: URLSession
    let baseURL: URL
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func call<E>(_ endpoint: E) async throws -> E.Success where E : Endpoint {
        let request = try prepareRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)
        
        guard response is HTTPURLResponse else {
            throw Error.unexpectedResponseType
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(E.Success.self, from: data)
    }
    
    func prepareRequest<E: Endpoint>(for endpoint: E) throws -> URLRequest {
        guard let url = endpoint.urlComponents.url(relativeTo: baseURL) else {
            throw Error.invalidRequest(endpoint)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        return request
    }
}
