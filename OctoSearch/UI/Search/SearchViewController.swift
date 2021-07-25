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
    }

    private func bindToViewModel() {
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(600), scheduler: typingScheduler)
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        title = L10n.Search.title
    }

    private func setupTableView() {
        var contentInset = tableView.contentInset
        contentInset.top = searchBar.bounds.height

        tableView.contentInset = contentInset

        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
    }
}
