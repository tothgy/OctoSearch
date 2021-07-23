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

     private let rootViewController = UINavigationController()

     func navigate(to step: Step) -> FlowContributors {
         guard let step = step as? AppStep else { return .none }

         switch step {
         default:
             return .none
         }
     }

 }
