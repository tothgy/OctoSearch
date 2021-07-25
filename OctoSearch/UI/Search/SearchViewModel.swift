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
    
    // MARK: - Output

    var cells$: Observable<[RepositoryCellModel]> { get }
    var showLoading$: Observable<Bool> { get }
}

class SearchViewModel: SearchViewModelProtocol, Stepper {

    // MARK: - Input

    var searchText: PublishRelay<String> = .init()
    
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

    init() {
        showLoading$ = showLoadingRelay.asObservable()

        cells$ = searchText
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
                            }))
            })
            .catchError({ [weak self] (error) -> Observable<[Repository]> in
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
            .map({ (repositories: [Repository]) -> [RepositoryCellModel] in
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
            })
            .retry()
            .share(replay: 1)
    }
}

