//
//  RepositoryCellModel.swift
//  OctoSearch
//

import Foundation
import RxSwift

struct RepositoryCellModel {
    let title: String
    let subtitle: String
    let selectionCompletable: Completable
}
