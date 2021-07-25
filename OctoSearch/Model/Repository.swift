//
//  Repository.swift
//  OctoSearch
//

import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let htmlUrl: String
    let repositoryDescription: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case repositoryDescription = "description"
    }
}
