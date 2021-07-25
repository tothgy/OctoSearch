//
//  AppFlowSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import Nimble
import Quick
import RxSwift
import Swinject
import RxFlow
import RxTest

// swiftlint:disable file_length
class AppFlowSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("AppFlow") {
            var sut: AppFlow!
            var testCoordinator: FlowCoordinator!
            var testStepper: TestStepper!
            var disposeBag: DisposeBag!

            beforeEach {
                MainAssembler.shared.create(with: TestAssembly())

                let container = MainAssembler.shared.container
                sut = container.resolve(AppFlow.self)

                testStepper = TestStepper()
                testCoordinator = FlowCoordinator()
                Flows.use(sut, when: .ready) { root in
                    presentAsInitialViewController(root)
                }
                testCoordinator.coordinate(flow: sut, with: testStepper)

                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            context("when the initial view is requested") {
                it("shows the Search view") {
                    testStepper.triggerStep(AppStep.rootViewRequested)

                    expect(sut.rootViewController.topViewController).to(beAKindOf(SearchViewController.self))
                }
            }
        }
    }
}

extension AppFlowSpec {
    
    class TestAssembly: MainAssemblyProtocol {
        var container: Container = .init()

        func assemble() {
            container.register(AppFlow.self) { _ in
                let instance = AppFlow()
                return instance
            }.inObjectScope(.transient)

            container.register(SearchViewModelProtocol.self) { _ in
                return MockSearchViewModel()
            }.inObjectScope(.transient)

            container.register(SchedulerType.self) { _ in
                return TestScheduler(initialClock: 0, resolution: 0.001)
            }.inObjectScope(.container)
        }
    }
}
