//
//  MockSearchViewModel.swift
//  OctoSearchTests
//

@testable import OctoSearch
import Foundation
import RxSwift

class MockSearchViewModelBase: SearchViewModelProtocol {

    var invokedCellsGetter = false
    var invokedCellsGetterCount = 0
    var stubbedCells: Observable<[RepositoryCellModel]>!

    var cells$: Observable<[RepositoryCellModel]> {
        invokedCellsGetter = true
        invokedCellsGetterCount += 1
        return stubbedCells
    }

    var invokedSearch = false
    var invokedSearchCount = 0
    var invokedSearchParameters: (searchText: String, Void)?
    var invokedSearchParametersList = [(searchText: String, Void)]()
    var stubbedSearchResult: Completable!

    func search(_ searchText: String) -> Completable {
        invokedSearch = true
        invokedSearchCount += 1
        invokedSearchParameters = (searchText, ())
        invokedSearchParametersList.append((searchText, ()))
        return stubbedSearchResult
    }
}

class MockSearchViewModel: MockSearchViewModelBase {
    override init() {
        super.init()
        stubbedSearchResult = .never()
        stubbedCells = cellsSubject
    }

    private let cellsSubject = ReplaySubject<[RepositoryCellModel]>.create(bufferSize: 1)
    func expectCellsToReturn(_ value: [RepositoryCellModel]) {
        cellsSubject.onNext(value)
    }
}
