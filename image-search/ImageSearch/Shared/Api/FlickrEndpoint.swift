//
//  FlickrEndpoint.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import Foundation

struct FlickrEndpoint<S: Decodable>: Endpoint {
    typealias Success = S

    let method: HTTPMethod
    let path: String
    let query: [URLQueryItem]?
}

extension FlickrEndpoint {
    static func search(query: String, page: Int? = nil) -> FlickrEndpoint<Search> {
        var queryItems: [URLQueryItem] = [
            .init(name: "method", value: "flickr.photos.search"),
            .init(name: "api_key", value: "<#API KEY#>"),
            .init(name: "text", value: query),
            .init(name: "format", value: "json"),
            .init(name: "nojsoncallback", value: "1"),
        ]

        if let page {
            queryItems.append(.init(name: "page", value: "\(page)"))
        }

        return FlickrEndpoint<Search>(
            method: .GET,
            path: "services/rest",
            query: queryItems
        )
    }
}
