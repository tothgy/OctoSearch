//
//  MockSearchViewModel.swift
//  OctoSearchTests
//

@testable import OctoSearch
import Foundation
import RxSwift
import RxRelay

class MockSearchViewModelBase: SearchViewModelProtocol {

    var invokedSearchTextGetter = false
    var invokedSearchTextGetterCount = 0
    var stubbedSearchText: PublishRelay<String>!

    var searchText: PublishRelay<String> {
        invokedSearchTextGetter = true
        invokedSearchTextGetterCount += 1
        return stubbedSearchText
    }

    var invokedCellsGetter = false
    var invokedCellsGetterCount = 0
    var stubbedCells: Observable<[RepositoryCellModel]>!

    var cells$: Observable<[RepositoryCellModel]> {
        invokedCellsGetter = true
        invokedCellsGetterCount += 1
        return stubbedCells
    }
}

class MockSearchViewModel: MockSearchViewModelBase {
    override init() {
        super.init()
        stubbedSearchText = .init()
        stubbedCells = cellsSubject
    }

    private let cellsSubject = ReplaySubject<[RepositoryCellModel]>.create(bufferSize: 1)
    func expectCellsToReturn(_ value: [RepositoryCellModel]) {
        cellsSubject.onNext(value)
    }
}
