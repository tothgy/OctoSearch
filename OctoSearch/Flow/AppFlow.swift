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
         case let .alert(alertDetails):
            return presentAlert(alertDetails: alertDetails)
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

    private func presentAlert(alertDetails: AlertDetails) -> FlowContributors {
        let alert: UIAlertController = .init(
            title: alertDetails.title,
            message: alertDetails.message,
            preferredStyle: .alert)

        for action in alertDetails.actions {
            alert.addAction(action.nativeAction)
        }

        rootViewController.present(alert, animated: true)

        return .none
    }
 }
