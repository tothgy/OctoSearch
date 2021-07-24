//
//  main.swift
//  OctoSearch
//

import Foundation
import UIKit

let appDelegateClass: AnyClass? = NSClassFromString("OctoSearchTests.TestingAppDelegate") ?? AppDelegate.self

_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(appDelegateClass!))
