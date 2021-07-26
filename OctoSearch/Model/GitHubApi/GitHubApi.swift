//
//  GitHubApi.swift
//  OctoSearch
//

import Foundation
import Moya

enum GitHubApi {
    case searchRepositories(query: String)
    case nextSearchPage(url: URL)
}

extension GitHubApi: TargetType {

    var baseURL: URL {
        switch self {
        case .searchRepositories:
            return URL(string: "https://api.github.com")!
        case let .nextSearchPage(url):
            return url
        }
    }
    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        case .nextSearchPage:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .searchRepositories:
            return .get
        case .nextSearchPage:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .searchRepositories(query):
            return .requestParameters(
                    parameters: ["q": query],
                    encoding: URLEncoding.default)
        case .nextSearchPage:
            return .requestPlain
        }
    }

    var sampleData: Data {
        return Data()
    }

    var validationType: ValidationType {
        return .customCodes(Array(200..<400))
    }

    var headers: [String: String]? {
        return [
            "Accept": "application/vnd.github.v3+json"
        ]
    }
}
