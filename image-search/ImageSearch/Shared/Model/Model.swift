//
//  Model.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.

import Foundation

// MARK: - Search
struct Search: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let photo: [Photo]
    let total: Int
}

// MARK: - Photo
struct Photo: Codable {
    let farm: Int
    let id: String
    let isfamily, isfriend, ispublic: Int
    let owner, secret, server, title: String
}

extension Photo: Hashable {}
