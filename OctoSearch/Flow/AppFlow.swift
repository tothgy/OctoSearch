//
//  AppFlow.swift
//  OctoSearch
//

import Foundation
import RxFlow

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
         }
     }

    private func showRootView() -> FlowContributors {
        let viewController = StoryboardScene.SearchViewController.initialScene.instantiate()

        rootViewController.setViewControllers([viewController], animated: false)

        return .one(
            flowContributor: .contribute(
                withNextPresentable: viewController,
                withNextStepper: DefaultStepper()))
    }
 }
