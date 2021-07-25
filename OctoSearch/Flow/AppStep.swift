//
//  AppStep.swift
//  OctoSearch
//

import Foundation
import RxFlow

enum AppStep: Step {
    case rootViewRequested
    case webViewRequested(url: URL)
    case alert(AlertDetails)
}
