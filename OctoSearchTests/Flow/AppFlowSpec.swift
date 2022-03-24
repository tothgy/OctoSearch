//
//  AppFlowSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import SafariServices
import Nimble
import Quick
import RxSwift
import Swinject
import RxFlow
import RxTest
import ViewControllerPresentationSpy
import InjectPropertyWrapper

// swiftlint:disable file_length
class AppFlowSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("AppFlow") {
            var sut: AppFlow!
            var testCoordinator: FlowCoordinator!
            var testStepper: TestStepper!
            var assembler: MainAssembler!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container

                let container = assembler.container
                sut = container.resolve(AppFlow.self)

                testStepper = TestStepper()
                testCoordinator = FlowCoordinator()
                Flows.use(sut, when: .ready) { root in
                    presentAsInitialViewController(root)
                }
                testCoordinator.coordinate(flow: sut, with: testStepper)
            }
            
            context("when the initial view is requested") {
                it("shows the Search view") {
                    testStepper.triggerStep(AppStep.rootViewRequested)

                    expect(sut.rootViewController.topViewController).to(beAKindOf(SearchViewController.self))
                }
            }

            context("when the Web view is requested") {
                it("shows the Web view for the given URL") {
                    let url: URL! = URL(string: "https://github.com")
                    testStepper.triggerStep(AppStep.webViewRequested(url: url))

                    expect(sut.rootViewController.presentedViewController)
                        .toEventually(beAKindOf(SFSafariViewController.self))
                }
            }

            context("when showing an alert is requested") {
                it("shows the alert") {
                    let alertVerifier = AlertVerifier()
                    let expectedAlert: AlertDetails = .init(
                        title: "Title",
                        message: "Message",
                        actions: [AlertAction(title: "OK", style: .cancel)])

                    testStepper.triggerStep(AppStep.alert(expectedAlert))

                    alertVerifier.verify(
                        title: expectedAlert.title,
                        message: expectedAlert.message,
                        animated: true,
                        actions: [
                            .cancel("OK")
                        ],
                        presentingViewController: sut.rootViewController
                    )
                }
            }
        }
    }
}

extension AppFlowSpec {
    
    class TestAssembly: Assembly {

        func assemble(container: Container) {
            container.register(AppFlow.self) { _ in
                let instance = AppFlow()
                return instance
            }.inObjectScope(.transient)

            container.register(SearchViewModelProtocol.self) { _ in
                return MockSearchViewModel()
            }.inObjectScope(.transient)

            container.register(SchedulerType.self) { _ in
                return TestScheduler(initialClock: 0, resolution: 0.001)
            }.inObjectScope(.transient)

            container.register(SearchServiceProtocol.self) { _ in
                return MockSearchService()
            }.inObjectScope(.transient)
        }
    }
}
