//
//  AppDelegate.swift
//  OctoSearch
//

import UIKit
import RxSwift
import RxFlow
import CocoaLumberjack

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let coordinator = FlowCoordinator()
    private let appFlow = AppFlow()
    private let disposeBag: DisposeBag = .init()

    let dependencyManager: MainAssembler = {
        let manager = MainAssembler.shared
        let assembler: MainAssemblyProtocol = MainAssembly()
        manager.create(with: assembler)
        return manager
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLogging()
        initiateFlow()

        return true
    }

    private func initiateFlow() {
        coordinator.rx.willNavigate
            .subscribe(onNext: { (flow, step) in
                DDLogDebug("Will navigate to flow=\(flow) and step=\(step)")
            })
            .disposed(by: disposeBag)

        coordinator.rx.didNavigate
            .subscribe(onNext: { (flow, step) in
                DDLogDebug("Did navigate to flow=\(flow) and step=\(step)")
            })
            .disposed(by: disposeBag)

        Flows.use(
            appFlow,
            when: .created) { [weak self] root in
            self?.window = UIWindow()
            self?.window?.rootViewController = root
            self?.window?.makeKeyAndVisible()
        }

        self.coordinator.coordinate(flow: appFlow, with: OneStepper(withSingleStep: AppStep.rootViewRequested))
    }

    private func setupLogging() {
        #if DEBUG
        dynamicLogLevel = .debug
        #else
        dynamicLogLevel = .error
        #endif

        if let ttyLogger = DDTTYLogger.sharedInstance {
            ttyLogger.logFormatter = LogFormatter()
            DDLog.add(ttyLogger) // TTY = Xcode console
        }
        let osLogger = DDOSLogger.sharedInstance
        osLogger.logFormatter = LogFormatter()
        DDLog.add(osLogger)
    }
}

