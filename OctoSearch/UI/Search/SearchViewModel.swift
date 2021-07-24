//
//  SearchViewModel.swift
//  OctoSearch
//

import RxSwift

protocol SearchViewModelProtocol {
    // MARK: - Input
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> { get }

    func search(_ searchText: String) -> Completable
}

class SearchViewModel: SearchViewModelProtocol {

    // MARK: - Input
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> = .never()

    // MARK: - Internal

    init() {
        
    }

    func search(_ searchText: String) -> Completable {
        return .never()
    }
}

