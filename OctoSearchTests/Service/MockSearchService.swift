//
//  MockSearchServiceSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import Nimble
import Quick
import RxSwift
import Swinject

// swiftlint:disable file_length
class MockSearchServiceBase: SearchServiceProtocol {

    var invokedSearch = false
    var invokedSearchCount = 0
    var invokedSearchParameters: (searchText: String, Void)?
    var invokedSearchParametersList = [(searchText: String, Void)]()
    var stubbedSearchResult: Single<[Repository]>!

    func search(_ searchText: String) -> Single<[Repository]> {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (searchText, ())
        invokedSearchParametersList.append((searchText, ()))
        return stubbedSearchResult
    }
}

class MockSearchService: MockSearchServiceBase {
    override init() {
        super.init()
        stubbedSearchResult = .never()
    }
}
