//
//  SearchService.swift
//  OctoSearch
//

import Foundation
import RxSwift
import Moya

protocol SearchServiceProtocol {
    func search(_ searchText: String) -> Single<([Repository], URL?)>
    func nextSearchPage(_ url: URL) -> Single<([Repository], URL?)>
}

class SearchService: SearchServiceProtocol {

    @Inject
    var moyaProvider: MoyaProvider<GitHubApi>

    func search(_ searchText: String) -> Single<([Repository], URL?)> {
        return moyaProvider.rx
            .request(GitHubApi.searchRepositories(query: searchText))
            .map({ response -> (Response, URL?) in
                if let urlReponse = response.response {
                    let nextUrl = try? SearchService.parseNextURL(urlReponse)

                    return (response, nextUrl)
                }
                return (response, nil)
            })
            .map({ (response: Response, nextPageUrl: URL?) -> (RepositorySearchResult, URL?) in
                let searchResults = try response.map(RepositorySearchResult.self)

                return (searchResults, nextPageUrl)
            })
            .map({ return ($0.0.items, $0.1) })
    }

    func nextSearchPage(_ url: URL) -> Single<([Repository], URL?)> {
        return moyaProvider.rx
            .request(GitHubApi.nextSearchPage(url: url))
            .map({ response -> (Response, URL?) in
                if let urlReponse = response.response {
                    let nextUrl = try? SearchService.parseNextURL(urlReponse)

                    return (response, nextUrl)
                }
                return (response, nil)
            })
            .map({ (response: Response, nextPageUrl: URL?) -> (RepositorySearchResult, URL?) in
                let searchResults = try response.map(RepositorySearchResult.self)

                return (searchResults, nextPageUrl)
            })
            .map({ return ($0.0.items, $0.1) })
    }
}

extension SearchService {

    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])

    private static func parseLinks(_ links: String) throws -> [String: String] {

        let length = (links as NSString).length
        let matches = SearchService.linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))

        var result: [String: String] = [:]

        for m in matches {
            let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                let range = m.range(at: rangeIndex)
                let startIndex = links.index(links.startIndex, offsetBy: range.location)
                let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                return String(links[startIndex ..< endIndex])
            }

            if matches.count != 2 {
                preconditionFailure("Error parsing links")
            }

            result[matches[1]] = matches[0]
        }

        return result
    }

    private static func parseNextURL(_ httpResponse: HTTPURLResponse) throws -> URL? {
        guard let serializedLinks = httpResponse.allHeaderFields["Link"] as? String else {
            return nil
        }

        let links = try SearchService.parseLinks(serializedLinks)

        guard let nextPageURL = links["next"] else {
            return nil
        }

        guard let nextUrl = URL(string: nextPageURL) else {
            preconditionFailure("Error parsing next url `\(nextPageURL)`")
        }

        return nextUrl
    }
}
