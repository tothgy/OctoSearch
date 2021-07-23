//
//  SearchViewController.swift
//  OctoSearch
//

import UIKit
import CocoaLumberjack
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
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

    }

    private func driveUI() {

    }

    private func bindToViewModel() {
        
    }
}
