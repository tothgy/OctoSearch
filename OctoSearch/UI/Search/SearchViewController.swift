//
//  SearchViewController.swift
//  OctoSearch
//

import UIKit
import CocoaLumberjack
import RxSwift
import RxCocoa
import RxFlow

class SearchViewController: UIViewController, HasStepper {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @Inject
    var viewModel: SearchViewModelProtocol
    @Inject
    var typingScheduler: SchedulerType

    var stepper: Stepper {
        return viewModel.stepper
    }

    private let disposeBag = DisposeBag()

    deinit {
        DDLogDebug("SearchViewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        driveUI()
        bindToViewModel()
    }
    
    // MARK: - Private

    private func setupUI() {
        setupNavigationBar()
        setupTableView()
    }

    private func driveUI() {
        viewModel.cells$
            .bind(
                to: tableView.rx.items,
                curriedArgument: { (tableView: UITableView, index: Int, cellModel: RepositoryCellModel) in
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: RepositoryCell.reuseIdentifier,
                        for: IndexPath(row: index, section: 0))

                    cell.imageView?.image = Asset.repo24.image
                    cell.textLabel?.text = cellModel.title
                    cell.detailTextLabel?.text = cellModel.subtitle

                    return cell
                })
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(RepositoryCellModel.self)
            .do(onNext: { [weak self] _ in
                if let selectedIndexPath = self?.tableView.indexPathForSelectedRow {
                    self?.tableView.deselectRow(at: selectedIndexPath, animated: true)
                }
            })
            .flatMap({ (selectedCellModel: RepositoryCellModel) -> Completable in
                return selectedCellModel.selectionCompletable
            })
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.showLoading$.asDriver(onErrorJustReturn: false)
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }

    private func bindToViewModel() {
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(600), scheduler: typingScheduler)
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        searchBar.rx.text.orEmpty
            .filter({ $0.isEmpty })
            .map({ _ in () })
            .bind(to: viewModel.clearResultsRelay)
            .disposed(by: disposeBag)

        tableView.rx.contentOffset
            .map({ [weak self] contentOffset -> Bool in
                guard let self = self else { return false }
                return self.tableView.isNearBottomEdge()
            })
            .filter({ $0 })
            .map({ _ in return () })
            .bind(to: viewModel.loadNextPageRelay)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        title = L10n.Search.title
    }

    private func setupTableView() {
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
    }
}

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}
