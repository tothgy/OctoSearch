//
//  AppFlow.swift
//  OctoSearch
//

import Foundation
import RxFlow
import SafariServices

class AppFlow: Flow {
     var root: Presentable {
         return self.rootViewController
     }

     let rootViewController = UINavigationController()

     func navigate(to step: Step) -> FlowContributors {
         guard let step = step as? AppStep else { return .none }

         switch step {
         case .rootViewRequested:
            return showRootView()
         case let .webViewRequested(url):
            return showWebView(withUrl: url)
         }
     }

    private func showRootView() -> FlowContributors {
        let viewController = StoryboardScene.SearchViewController.initialScene.instantiate()

        rootViewController.setViewControllers([viewController], animated: false)

        return .one(
            flowContributor: .contribute(
                withNextPresentable: viewController,
                withNextStepper: viewController.stepper))
    }

    private func showWebView(withUrl url: URL) -> FlowContributors {
        let webViewController = SFSafariViewController(url: url)

        rootViewController.present(webViewController, animated: true)

        return .one(
            flowContributor: .contribute(
                withNextPresentable: webViewController,
                withNextStepper: DefaultStepper()))
    }
 }
