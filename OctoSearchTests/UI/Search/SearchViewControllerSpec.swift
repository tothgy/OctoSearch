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
import RxTest

// swiftlint:disable file_length function_body_length
class SearchViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe("SearchViewController") {
            var sut: SearchViewController!
            var mockViewModel: MockSearchViewModel!
            var testScheduler: TestScheduler!
            var disposeBag: DisposeBag!

            beforeEach {
                MainAssembler.shared.create(with: TestAssembly())
                let container = MainAssembler.shared.container

                sut = container.get(SearchViewController.self)
                mockViewModel = container.get(SearchViewModelProtocol.self) as? MockSearchViewModel
                testScheduler = container.get(SchedulerType.self) as? TestScheduler
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            it("can be instantiated") {
                expect(sut).toNot(beNil())
            }

            context("when the view is loaded") {
                beforeEach {
                    sut.loadViewIfNeeded()
                }

                it("shows the title") {
                    expect(sut.title).to(equal("GitHub repositories"))
                }

                it("has a search bar") {
                    expect(sut.searchBar).toNot(beNil())
                }

                it("has a table view for the search results") {
                    expect(sut.tableView).toNot(beNil())
                }
            }

            context("when the view model signals a list of cell models") {
                beforeEach {
                    sut.loadViewIfNeeded()
                    mockViewModel.expectCellsToReturn([
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty())
                    ])
                }

                it("shows a cell for each cell model") {
                    expect(sut.tableView.numberOfSections).to(equal(1))
                    expect(sut.tableView.numberOfRows(inSection: 0)).to(equal(1))
                }

                context("each row") {
                    var cell: UITableViewCell!

                    beforeEach {
                        cell = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                    }

                    it("shows the repository icon") {
                        expect(cell.imageView?.image).to(equal(Asset.repo24.image))
                    }

                    it("shows the title") {
                        expect(cell.textLabel?.text).to(equal("Title"))
                    }

                    it("shows the subtitle") {
                        expect(cell.detailTextLabel?.text).to(equal("Subtitle"))
                    }
                }
            }

            context("given that the user entered a search term into the search bar") {
                context("and less than 600ms passed since the user finished typing") {
                    it("does not request the view model to search") {
                        sut.loadViewIfNeeded()

                        subscribe(
                            to: mockViewModel.searchText.asObservable(),
                            trigger: {
                                sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "a")

                                testScheduler.advanceTo(590)
                            },
                            verify: {(emissions: [String]) in
                                expect(emissions).to(beEmpty())
                            }).disposed(by: disposeBag)
                    }
                }

                context("and more than 600ms passed since the user finished typing") {
                    it("requests the view model to search with the given search term") {
                        sut.loadViewIfNeeded()

                        subscribe(
                            to: mockViewModel.searchText.asObservable(),
                            trigger: {
                                sut.searchBar.text = "a"
                                sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "foo")

                                testScheduler.advanceTo(600)
                            },
                            verify: {(emissions: [String]) in
                                expect(emissions).to(haveCount(1))
                                expect(emissions.last).to(equal("a"))
                            }).disposed(by: disposeBag)
                    }
                }

                context("and then entered the same text again and more than 600ms passed since the second input") {
                    it("does not request the view model to search") {
                        sut.loadViewIfNeeded()

                        subscribe(
                            to: mockViewModel.searchText.asObservable(),
                            trigger: {
                                sut.searchBar.text = "a"
                                sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "a")

                                testScheduler.advanceTo(600)

                                sut.searchBar.text = "a"
                                sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "a")

                                testScheduler.advanceTo(1200)
                            },
                            verify: {(emissions: [String]) in
                                expect(emissions).to(haveCount(1))
                                expect(emissions.last).to(equal("a"))
                            }).disposed(by: disposeBag)
                    }
                }
            }

            context("""
                given that the view model signalled a list of cell models \
                and the user taps on a row
                """) {
                it("subscribes to the selection observable in the corresponding cell model") {
                    sut.loadViewIfNeeded()
                    let selectionExpectation = QuickSpec.current.expectation(description: "selection")
                    mockViewModel.expectCellsToReturn([
                        RepositoryCellModel(
                            title: "Title",
                            subtitle: "Subtitle",
                            selectionCompletable: .create(subscribe: { (completable) -> Disposable in
                                selectionExpectation.fulfill()
                                completable(.completed)
                                return Disposables.create()
                            }))
                    ])

                    sut.tableView.delegate?.tableView?(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

                    QuickSpec.current.waitForExpectations(timeout: 1)
                }
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
                return MockSearchViewModel()
            }.inObjectScope(.container)

            container.register(SchedulerType.self) { _ in
                return TestScheduler(initialClock: 0, resolution: 0.001)
            }.inObjectScope(.container)
        }
    }
}
