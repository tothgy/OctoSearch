//
//  SearchViewModel.swift
//  OctoSearch
//

import RxSwift
import RxRelay
import RxFlow

protocol SearchViewModelProtocol: HasStepper {
    // MARK: - Input

    var searchText: PublishRelay<String> { get }
    var loadNextPageRelay: PublishRelay<()> { get }
    var clearResultsRelay: PublishRelay<()> { get }
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> { get }
    var showLoading$: Observable<Bool> { get }
}

class SearchViewModel: SearchViewModelProtocol, Stepper {

    // MARK: - Input

    var searchText: PublishRelay<String> = .init()
    var loadNextPageRelay: PublishRelay<()> = .init()
    var clearResultsRelay: PublishRelay<()> = .init()
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> = .never()
    var showLoading$: Observable<Bool> = .never()

    // MARK: - Internal

    @Inject
    var searchService: SearchServiceProtocol

    var stepper: Stepper {
        return self
    }

    var steps: PublishRelay<Step> = .init()

    private let showLoadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let nextPageSubject: ReplaySubject<URL> = .create(bufferSize: 1)

    init() {
        showLoading$ = showLoadingRelay.asObservable()

        let nextPageRequest$ = loadNextPageRelay
            .withLatestFrom(nextPageSubject)
            .distinctUntilChanged()
            .do(onNext: { [weak self] _ in
                self?.showLoadingRelay.accept(true)
            })
            .flatMapLatest({ [weak self] (nextPageUrl: URL) -> Observable<[Repository]> in
                guard let self = self else { return .just([]) }
                return self.searchService.nextSearchPage(nextPageUrl)
                    .do(onSuccess: { [weak self] (_, nextPageUrl) in
                        if let nextPageUrl = nextPageUrl {
                            self?.nextPageSubject.onNext(nextPageUrl)
                        }
                    })
                    .map({ (repositories, _) in return repositories })
                    .asObservable()
            })
            .do(onNext: { [weak self] _ in
                self?.showLoadingRelay.accept(false)
            })
            .flatMap({ [weak self] (newRepositories: [Repository]) -> Observable<[RepositoryCellModel]> in
                guard let self = self else { return .empty() }
                return self.cells$.take(1).map({ return $0 + self.createCellModels(fromRepositories: newRepositories)})
            })

        let searchResults$ = searchText
            .filter({ !$0.isEmpty })
            .do(onNext: { [weak self] _ in
                self?.showLoadingRelay.accept(true)
            })
            .flatMapLatest({ [weak self] (searchText: String) -> Observable<[Repository]> in
                guard let self = self else { return .just([]) }
                return Observable<[Repository]>.just([])
                    .concat(
                        self.searchService.search(searchText)
                            .do(onSuccess: { [weak self] _ in
                                self?.showLoadingRelay.accept(false)
                            })
                            .do(onSuccess: { [weak self] (_, nextPageUrl) in
                                if let nextPageUrl = nextPageUrl {
                                    self?.nextPageSubject.onNext(nextPageUrl)
                                }
                            })
                            .map({ (repositories, _) in return repositories })
                    )
            })
            .map({ [weak self] (repositories: [Repository]) -> [RepositoryCellModel] in
                guard let self = self else { return [] }
                return self.createCellModels(fromRepositories: repositories)
            })

        let clearResults$: Observable<[RepositoryCellModel]> = clearResultsRelay.asObservable()
            .map({ _ -> [RepositoryCellModel] in
                return []
            })

        cells$ = Observable.merge(searchResults$, nextPageRequest$, clearResults$)
            .catchError({ [weak self] (error) -> Observable<[RepositoryCellModel]> in
                let alertDetails: AlertDetails = .init(
                    title: L10n.Alert.Error.title,
                    message: error.localizedDescription,
                    error: nil,
                    actions: [
                        .okAction
                    ])

                self?.showLoadingRelay.accept(false)
                self?.steps.accept(AppStep.alert(alertDetails))
                return .error(error)
            })
            .retry()
            .share(replay: 1)
    }

    private func createCellModels(fromRepositories repositories: [Repository]) -> [RepositoryCellModel] {
        return repositories.map({ (repository: Repository) in
            return RepositoryCellModel(
                title: repository.fullName,
                subtitle: repository.repositoryDescription,
                selectionCompletable: .create(subscribe: { [weak self] (completable) -> Disposable in
                    guard let repositoryUrl = URL(string: repository.htmlUrl) else {
                        return Disposables.create()
                    }

                    self?.steps.accept(AppStep.webViewRequested(url: repositoryUrl))
                    completable(.completed)
                    return Disposables.create()
                }))
        })
    }
}

