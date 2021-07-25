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
    var stubbedSearchResult: Single<([Repository], URL?)>!

    func search(_ searchText: String) -> Single<([Repository], URL?)> {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (searchText, ())
        invokedSearchParametersList.append((searchText, ()))
        return stubbedSearchResult
    }

    var invokedNextSearchPage = false
    var invokedNextSearchPageCount = 0
    var invokedNextSearchPageParameters: (url: URL, Void)?
    var invokedNextSearchPageParametersList = [(url: URL, Void)]()
    var stubbedNextSearchPageResult: Single<([Repository], URL?)>!

    func nextSearchPage(_ url: URL) -> Single<([Repository], URL?)> {
        invokedNextSearchPage = true
        invokedNextSearchPageCount += 1
        invokedNextSearchPageParameters = (url, ())
        invokedNextSearchPageParametersList.append((url, ()))
        return stubbedNextSearchPageResult
    }
}

class MockSearchService: MockSearchServiceBase {
    override init() {
        super.init()
        stubbedSearchResult = .never()
        stubbedNextSearchPageResult = .never()
    }
}
