//
//  MockSearchViewModel.swift
//  OctoSearchTests
//

@testable import OctoSearch
import Foundation
import RxSwift
import RxRelay
import RxFlow

class MockSearchViewModelBase: SearchViewModelProtocol {

    var invokedSearchTextGetter = false
    var invokedSearchTextGetterCount = 0
    var stubbedSearchText: PublishRelay<String>!

    var searchText: PublishRelay<String> {
        invokedSearchTextGetter = true
        invokedSearchTextGetterCount += 1
        return stubbedSearchText
    }

    var invokedLoadNextPageRelayGetter = false
    var invokedLoadNextPageRelayGetterCount = 0
    var stubbedLoadNextPageRelay: PublishRelay<()>!

    var loadNextPageRelay: PublishRelay<()> {
        invokedLoadNextPageRelayGetter = true
        invokedLoadNextPageRelayGetterCount += 1
        return stubbedLoadNextPageRelay
    }

    var invokedCellsGetter = false
    var invokedCellsGetterCount = 0
    var stubbedCells: Observable<[RepositoryCellModel]>!

    var cells$: Observable<[RepositoryCellModel]> {
        invokedCellsGetter = true
        invokedCellsGetterCount += 1
        return stubbedCells
    }

    var invokedShowLoadingGetter = false
    var invokedShowLoadingGetterCount = 0
    var stubbedShowLoading: Observable<Bool>!

    var showLoading$: Observable<Bool> {
        invokedShowLoadingGetter = true
        invokedShowLoadingGetterCount += 1
        return stubbedShowLoading
    }

    var invokedStepperGetter = false
    var invokedStepperGetterCount = 0
    var stubbedStepper: Stepper!

    var stepper: Stepper {
        invokedStepperGetter = true
        invokedStepperGetterCount += 1
        return stubbedStepper
    }
}

class MockSearchViewModel: MockSearchViewModelBase {
    override init() {
        super.init()
        stubbedSearchText = .init()
        stubbedLoadNextPageRelay = .init()
        stubbedCells = cellsSubject
        stubbedShowLoading = showLoadingSubject
        stubbedStepper = DefaultStepper()
    }

    private let cellsSubject = ReplaySubject<[RepositoryCellModel]>.create(bufferSize: 1)
    func expectCellsToReturn(_ value: [RepositoryCellModel]) {
        cellsSubject.onNext(value)
    }

    private let showLoadingSubject = ReplaySubject<Bool>.create(bufferSize: 1)
    func expectShowLoadingToReturn(_ value: Bool) {
        showLoadingSubject.onNext(value)
    }
}
