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
    let repositoryDescription: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case repositoryDescription = "description"
    }

    init(id: Int, name: String, fullName: String, htmlUrl: String, repositoryDescription: String?) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.htmlUrl = htmlUrl
        self.repositoryDescription = repositoryDescription
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.fullName = try container.decode(String.self, forKey: .fullName)
        self.htmlUrl = try container.decode(String.self, forKey: .htmlUrl)
        self.repositoryDescription = try container.decodeIfPresent(String.self, forKey: .repositoryDescription)
    }
}
