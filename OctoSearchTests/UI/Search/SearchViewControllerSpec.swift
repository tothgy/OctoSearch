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
import InjectPropertyWrapper

// swiftlint:disable file_length function_body_length
class SearchViewControllerSpec: QuickSpec {
    
    override func spec() {
        describe("SearchViewController") {
            var sut: SearchViewController!
            var mockViewModel: MockSearchViewModel!
            var testScheduler: TestScheduler!
            var assembler: MainAssembler!
            var disposeBag: DisposeBag!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container

                sut = assembler.resolver.resolve(SearchViewController.self)
                mockViewModel = sut.viewModel as? MockSearchViewModel
                testScheduler = assembler.container.resolve(SchedulerType.self) as? TestScheduler
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
                assembler.dispose()
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

                it("shows the placeholder text in the search bar") {
                    expect(sut.searchBar.placeholder).to(equal("Search GitHub"))
                }

                it("has a table view for the search results") {
                    expect(sut.tableView).toNot(beNil())
                }

                it("has an empty message label") {
                    expect(sut.emptyLabel).toNot(beNil())
                    expect(sut.tableView.backgroundView).to(equal(sut.emptyLabel))
                }
            }

            context("when the view model signals a list of cell models") {
                beforeEach {
                    sut.loadViewIfNeeded()
                    mockViewModel.searchText.accept("")
                    mockViewModel.expectCellsToReturn([
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty())
                    ])
                }

                it("hides the empty message") {
                    expect(sut.emptyLabel.isHidden).to(beTrue())
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

            context("""
                given that the user entered text into the search bar \
                and the loading has been finished \
                and the view model signals an empty list of cell models
                """) {
                it("shows the no results empty message") {
                    sut.loadViewIfNeeded()
                    sut.searchBar.text = "a"
                    sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "a")
                    testScheduler.advanceTo(600)
                    mockViewModel.expectShowLoadingToReturn(false)
                    mockViewModel.expectCellsToReturn([])

                    expect(sut.emptyLabel.isHidden).to(beFalse())
                    expect(sut.emptyLabel.text).to(equal("We couldn’t find any repositories matching the given term"))
                }
            }

            context("given that the user entered a search term into the search bar") {
                context("and less than 600ms passed since the user finished typing") {
                    it("does not update the view model's search text yet") {
                        sut.loadViewIfNeeded()

                        subscribe(
                            to: mockViewModel.searchText.asObservable(),
                            trigger: {
                                sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "a")

                                testScheduler.advanceTo(590)
                            },
                            verify: {(emissions: [String]) in
                                expect(emissions.last).to(beEmpty())
                            }).disposed(by: disposeBag)
                    }
                }

                context("and more than 600ms passed since the user finished typing") {
                    it("updates the view model's search terms") {
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

            context("""
                given that the view model signalled a list of cell models \
                and the user scrolls to the bottom of the result list
                """) {
                it("requests the view model to load the next result page") {
                    sut.loadViewIfNeeded()

                    mockViewModel.expectCellsToReturn([
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty()),
                        RepositoryCellModel(title: "Title", subtitle: "Subtitle", selectionCompletable: .empty())
                    ])

                    subscribe(
                        to: mockViewModel.loadNextPageRelay.asObservable(),
                        trigger: {
                            sut.tableView.contentOffset = .init(x: 0, y: sut.tableView.contentSize.height)
                            waitUntil { (done) in
                                DispatchQueue.main.async {
                                    done()
                                }
                            }
                        },
                        verify: {(emissions: [()]) in
                            expect(emissions).to(haveCount(1))
                        }).disposed(by: disposeBag)
                }
            }

            context("""
                given that the view model has signaled a list a cell models
                and the user has entered text into search field
                when the view models signals to show the loading activity indicator
                """) {
                beforeEach {
                    sut.loadViewIfNeeded()
                    mockViewModel.expectCellsToReturn([])
                    mockViewModel.searchText.accept("")

                    mockViewModel.expectShowLoadingToReturn(true)
                }

                it("shows the activity indicator") {
                    expect(sut.activityIndicator.isAnimating).to(beTrue())
                }

                it("hides the empty message") {
                    expect(sut.emptyLabel.isHidden).to(beTrue())
                }
            }

            context("""
                given that the view model has signaled a list a cell models
                and the user has entered text into search field
                when the view models signals to hide the loading activity indicator
                """) {
                beforeEach {
                    sut.loadViewIfNeeded()
                    mockViewModel.expectCellsToReturn([])
                    mockViewModel.searchText.accept("")

                    mockViewModel.expectShowLoadingToReturn(false)
                }

                it("hides the activity indicator") {
                    sut.loadViewIfNeeded()
                    mockViewModel.expectShowLoadingToReturn(false)

                    expect(sut.activityIndicator.isAnimating).to(beFalse())
                }
            }

            context("""
                given that there is text in the search bar input field \
                and the user clears the search bar input text
                """) {
                it("updates the view model's search text immediately") {
                    sut.loadViewIfNeeded()
                    sut.searchBar.text = "a"

                    subscribe(
                        to: mockViewModel.searchText.asObservable(),
                        trigger: {
                            sut.searchBar.text = ""
                            sut.searchBar.delegate?.searchBar?(sut.searchBar, textDidChange: "")
                        },
                        verify: {(emissions: [String]) in
                            expect(emissions.last).to(beEmpty())
                        }).disposed(by: disposeBag)
                }
            }
        }
    }
}

extension SearchViewControllerSpec {
    
    class TestAssembly: Assembly {

        func assemble(container: Container) {
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
