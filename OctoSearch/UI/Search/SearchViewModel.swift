//
//  SearchViewModel.swift
//  OctoSearch
//

import RxSwift
import RxRelay

protocol SearchViewModelProtocol {
    // MARK: - Input

    var searchText: PublishRelay<String> { get }
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> { get }
}

class SearchViewModel: SearchViewModelProtocol {

    // MARK: - Input

    var searchText: PublishRelay<String> = .init()
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> = .never()

    // MARK: - Internal

    @Inject
    var searchService: SearchServiceProtocol

    init() {
        cells$ = searchText
            .flatMapLatest({ [weak self] (searchText: String) -> Single<[Repository]> in
                guard let self = self else { return .just([]) }
                return self.searchService.search(searchText)
            })
            .map({ (repositories: [Repository]) -> [RepositoryCellModel] in
                return repositories.map({
                    return RepositoryCellModel(
                        title: $0.fullName,
                        subtitle: $0.repositoryDescription,
                        selectionCompletable: .empty())
                })
            })
            .share(replay: 1)
    }
}

