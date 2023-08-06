//
//  Endpoint.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

enum HTTPMethod: String {
    case GET
}

/// Any endpoint that can be used to call remote service and receive decodable response
protocol Endpoint {
    associatedtype Success: Decodable
    
    var path: String { get }
    var query: [URLQueryItem]? { get }
    var method: HTTPMethod { get }
}

extension Endpoint {
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.path = path
        components.queryItems = query
        return components
    }
}
