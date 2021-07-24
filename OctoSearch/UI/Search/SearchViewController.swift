//
//  SearchViewController.swift
//  OctoSearch
//

import UIKit
import CocoaLumberjack
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    @Inject
    var viewModel: SearchViewModelProtocol
    @Inject
    var typingScheduler: SchedulerType

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
    }

    private func bindToViewModel() {
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(600), scheduler: typingScheduler)
            .flatMap({ [weak self] (searchTerm: String) -> Completable in
                guard let self = self else { return .empty() }
                return self.viewModel.search(searchTerm)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        var contentInset = tableView.contentInset
        contentInset.top = searchBar.bounds.height

        tableView.contentInset = contentInset

        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
    }
}
