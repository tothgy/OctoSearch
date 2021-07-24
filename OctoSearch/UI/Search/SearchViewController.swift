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
    var viewModel: SearchViewModelProtocol!
    var disposeBag = DisposeBag()

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
        var contentInset = tableView.contentInset
        contentInset.top = searchBar.bounds.height

        tableView.contentInset = contentInset
    }

    private func driveUI() {

    }

    private func bindToViewModel() {
        
    }
}
