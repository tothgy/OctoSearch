//
//  SearchService.swift
//  OctoSearch
//

import Foundation
import RxSwift

protocol SearchServiceProtocol {
    func search(_ searchText: String) -> Single<[Repository]>
}

class SearchService: SearchServiceProtocol {
    func search(_ searchText: String) -> Single<[Repository]> {
        return .never()
    }
}
