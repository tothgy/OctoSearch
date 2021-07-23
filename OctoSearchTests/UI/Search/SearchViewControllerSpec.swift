//
//  SearchViewControllerSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import Nimble
import Quick
import Swinject
import SwinjectStoryboard
import UIKit
import RxSwift
import RxCocoa

// swiftlint:disable file_length function_body_length
class SearchViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe("SearchViewController") {
            var sut: SearchViewController!
            var mockViewModel: MockSearchViewModel!
            var disposeBag: DisposeBag!

            beforeEach {
                MainAssembler.shared.create(with: TestAssembly())
                let container = MainAssembler.shared.container
                sut = container.get(SearchViewController.self)
                mockViewModel = container.get(SearchViewModelProtocol.self) as? MockSearchViewModel
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            it("can be instantiated") {
                expect(sut).toNot(beNil())
            }
        }
    }
}

extension SearchViewControllerSpec {
    
    class TestAssembly: MainAssemblyProtocol {
        let container: Container = .init()

        func assemble() {
            container.register(SearchViewController.self) { _ in
                let instance = StoryboardScene.SearchViewController.initialScene.instantiate()
                return instance
            }.inObjectScope(.transient)

            container.register(SearchViewModelProtocol.self) { _ in
                let instance = MockSearchViewModel()
                return instance
            }.inObjectScope(.container)
        }
    }
    
    class MockSearchViewModel: SearchViewModelProtocol {
        
        private var disposeBag = DisposeBag()
        
        init() {
            
        }
    }
}
