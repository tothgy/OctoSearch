//
//  SearchService.swift
//  OctoSearch
//

import Foundation
import RxSwift
import Moya

protocol SearchServiceProtocol {
    func search(_ searchText: String) -> Single<[Repository]>
}

class SearchService: SearchServiceProtocol {

    @Inject
    var moyaProvider: MoyaProvider<GitHubApi>

    func search(_ searchText: String) -> Single<[Repository]> {
        return moyaProvider.rx
            .request(GitHubApi.searchRepositories(query: searchText))
            .map(RepositorySearchResult.self)
            .map({ return $0.items })
    }
}
