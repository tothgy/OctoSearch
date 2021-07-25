//
//  RepositorySearchResult.swift
//  OctoSearch
//

import Foundation

struct RepositorySearchResult: Decodable {
    let totalCount: Int
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items = "items"
    }
}
