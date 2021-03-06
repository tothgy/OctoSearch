//
//  SearchViewModelSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import Nimble
import Quick
import Swinject
import SwinjectStoryboard
import RxCocoa
import RxSwift
import RxFlow
import InjectPropertyWrapper

// swiftlint:disable file_length function_body_length
class SearchViewModelSpec: QuickSpec {

    override func spec() {
        describe("SearchViewModel") {
            var sut: SearchViewModel!
            var mockSearchService: MockSearchService!
            var assembler: MainAssembler!
            var disposeBag: DisposeBag!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container

                let container = assembler.container
                sut = container.resolve(SearchViewModel.self)
                mockSearchService = container.resolve(SearchServiceProtocol.self) as? MockSearchService
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            it("is a Stepper") {
                expect(sut).to(beAKindOf(Stepper.self))
            }

            describe("cells$") {
                context("given that a search text has been published") {
                    it("emits an empty list to clear the search results") {
                        subscribe(
                            to: sut.cells$,
                            trigger: {
                                sut.searchText.accept("repo")
                            },
                            verify: {(emissions: [[RepositoryCellModel]]) in
                                expect(emissions).to(haveCount(1))
                                let cellModels = emissions.last!
                                expect(cellModels).to(haveCount(0))
                            }).disposed(by: disposeBag)
                    }

                    context("and the Search Service returned a list of Repositories") {
                        var expectedRepository: Repository!

                        beforeEach {
                            expectedRepository = .init(
                                id: 1,
                                name: "Repo-1",
                                fullName: "Repository 1",
                                htmlUrl: "https://github.com/repo",
                                repositoryDescription: "Repo description")

                            mockSearchService.stubbedSearchResult = .just((
                                [expectedRepository],
                                URL(string: "")
                            ))
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's title is the corresponding Repository's full name
                        """) {
                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.searchText.accept("repo")
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(1))
                                    let cellModel = cellModels.last!
                                    expect(cellModel.title).to(equal(expectedRepository.fullName))
                                }).disposed(by: disposeBag)
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's subtitle is the corresponding Repository's description
                        """) {
                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.searchText.accept("repo")
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(1))
                                    let cellModel = cellModels.last!
                                    expect(cellModel.subtitle).to(equal(expectedRepository.repositoryDescription))
                                }).disposed(by: disposeBag)
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's selection completable requests to show a web view with the correspoding \
                        Repository's HTML URL on subscribe
                        """) {
                            var selectionCompletable: Completable!

                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.searchText.accept("repo")
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(1))
                                    let cellModel = cellModels.last!
                                    selectionCompletable = cellModel.selectionCompletable
                                }).disposed(by: disposeBag)

                            subscribe(
                                to: sut.steps.asObservable(),
                                trigger: {
                                    selectionCompletable.subscribe().disposed(by: disposeBag)
                                },
                                verify: {(emissions: [Step]) in
                                    expect(emissions).to(haveCount(1))

                                    guard
                                        let appStep = emissions.last as? AppStep,
                                        case let AppStep.webViewRequested(url) = appStep,
                                        url.absoluteString == "https://github.com/repo"
                                    else {
                                        fail("""
                                        Expected to get AppStep.webViewRequested("https://github.com/repo") \
                                        got: \(String(describing: emissions.last))
                                        """)
                                        return
                                    }
                                }).disposed(by: disposeBag)
                        }
                    }
                }

                context("""
                    given that a search text has been published \
                    and the Search Service returned and array of Repositories and an URL of the next result page \
                    and loading the next page is requested
                    """) {
                    beforeEach {
                        sut.cells$.subscribe().disposed(by: disposeBag)

                        let expectedRepository: Repository = .init(
                            id: 1,
                            name: "Repo-1",
                            fullName: "Repository 1",
                            htmlUrl: "https://github.com/repo",
                            repositoryDescription: "Repo description")

                        mockSearchService.stubbedSearchResult = .just((
                            [expectedRepository],
                            URL(string: "https://github.com/repos-2")
                        ))

                        sut.searchText.accept("repo")
                    }

                    context("and the Search Services returned a list of Repositories") {
                        var expectedRepository: Repository!

                        beforeEach {
                            expectedRepository = .init(
                                id: 1,
                                name: "Repo-2",
                                fullName: "Repository 2",
                                htmlUrl: "https://github.com/repo2",
                                repositoryDescription: "Repo 2 description")

                            mockSearchService.stubbedNextSearchPageResult = .just((
                                [expectedRepository],
                                URL(string: "")
                            ))
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's title is the corresponding Repository's full name
                        """) {
                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.loadNextPageRelay.accept(())
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(2))
                                    let cellModel = cellModels.last!
                                    expect(cellModel.title).to(equal(expectedRepository.fullName))
                                }).disposed(by: disposeBag)
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's subtitle is the corresponding Repository's description
                        """) {
                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.loadNextPageRelay.accept(())
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(2))
                                    let cellModel = cellModels.last!
                                    expect(cellModel.subtitle).to(equal(expectedRepository.repositoryDescription))
                                }).disposed(by: disposeBag)
                        }

                        it("""
                        emits a list of cell models where \
                        each cell model's selection completable requests to show a web view with the correspoding \
                        Repository's HTML URL on subscribe
                        """) {
                            var selectionCompletable: Completable!

                            subscribe(
                                to: sut.cells$,
                                trigger: {
                                    sut.loadNextPageRelay.accept(())
                                },
                                verify: {(emissions: [[RepositoryCellModel]]) in
                                    expect(emissions).to(haveCount(2))
                                    let cellModels = emissions.last!
                                    expect(cellModels).to(haveCount(2))
                                    let cellModel = cellModels.last!
                                    selectionCompletable = cellModel.selectionCompletable
                                }).disposed(by: disposeBag)

                            subscribe(
                                to: sut.steps.asObservable(),
                                trigger: {
                                    selectionCompletable.subscribe().disposed(by: disposeBag)
                                },
                                verify: {(emissions: [Step]) in
                                    expect(emissions).to(haveCount(1))

                                    guard
                                        let appStep = emissions.last as? AppStep,
                                        case let AppStep.webViewRequested(url) = appStep,
                                        url.absoluteString == "https://github.com/repo2"
                                    else {
                                        fail("""
                                        Expected to get AppStep.webViewRequested("https://github.com/repo") \
                                        got: \(String(describing: emissions.last))
                                        """)
                                        return
                                    }
                                }).disposed(by: disposeBag)
                        }

                        context("""
                            and then an empty search term is published
                            and loading the next page is requested
                            """) {
                            it("emits an empty list of cell models") {
                                subscribe(
                                    to: sut.cells$,
                                    trigger: {
                                        sut.searchText.accept("")
                                        sut.loadNextPageRelay.accept(())
                                    },
                                    verify: {(emissions: [[RepositoryCellModel]]) in
                                        expect(emissions).to(haveCount(3))
                                        let cellModels = emissions.last!
                                        expect(cellModels).to(beEmpty())
                                    }).disposed(by: disposeBag)

                            }

                            context("""
                                and then a new search term is published
                                and loading the next page is requested
                                """) {
                                it("emits an empty list of cell models") {
                                    subscribe(
                                        to: sut.cells$,
                                        trigger: {
                                            sut.searchText.accept("")
                                            sut.loadNextPageRelay.accept(())
                                        },
                                        verify: {(emissions: [[RepositoryCellModel]]) in
                                            expect(emissions).to(haveCount(3))
                                            let cellModels = emissions.last!
                                            expect(cellModels).to(beEmpty())
                                        }).disposed(by: disposeBag)

                                }
                        }
                    }
                }
            }

            describe("showLoading$") {
                it("emits 'false' by default") {
                    subscribe(to: sut.showLoading$) { (emissions: [Bool]) in
                        expect(emissions.last).to(beFalse())
                    }.disposed(by: disposeBag)
                }

                context("when the first search text is published") {
                    it("emits 'true'") {
                        sut.cells$.subscribe().disposed(by: disposeBag)

                        subscribe(
                            to: sut.showLoading$,
                            trigger: {
                                sut.searchText.accept("a")
                            },
                            verify: {(emissions: [Bool]) in
                                expect(emissions.last).to(beTrue())
                            }).disposed(by: disposeBag)
                    }

                    context("and the search request returns successfully") {
                        beforeEach {
                            mockSearchService.stubbedSearchResult = .just(([], URL(string: "")))
                        }

                        it("emits 'false'") {
                            subscribe(
                                to: sut.showLoading$,
                                trigger: {
                                    sut.searchText.accept("a")
                                },
                                verify: {(emissions: [Bool]) in
                                    expect(emissions.last).to(beFalse())
                                }).disposed(by: disposeBag)
                        }
                    }

                    context("and the search request fails") {
                        beforeEach {
                            mockSearchService.stubbedSearchResult = .error(NSError())
                        }

                        it("emits 'false'") {
                            subscribe(
                                to: sut.showLoading$,
                                trigger: {
                                    sut.searchText.accept("a")
                                },
                                verify: {(emissions: [Bool]) in
                                    expect(emissions.last).to(beFalse())
                                }).disposed(by: disposeBag)
                        }
                    }
                }
            }

            context("given that an empty string has been published on the search text") {
                it("does not request the Search Service to search") {
                    sut.cells$.subscribe().disposed(by: disposeBag)
                    sut.searchText.accept("")

                    expect(mockSearchService.invokedSearchCount).to(equal(0))
                }
            }

            context("when a search request fails") {
                let expectedAlertDetails: AlertDetails = .init(
                    title: "Error",
                    message: "Localized description",
                    actions: [AlertAction(title: "OK", style: .default)])

                beforeEach {
                    sut.cells$.subscribe().disposed(by: disposeBag)

                    mockSearchService.stubbedSearchResult = .error(
                        NSError(
                            domain: "ApiError",
                            code: -1,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Localized description"
                            ]))
                }

                it("requests to show an error alert") {
                    subscribe(
                        to: sut.steps.asObservable(),
                        trigger: {
                            sut.searchText.accept("a")
                        },
                        verify: {(emissions: [Step]) in
                            expect(emissions).to(haveCount(1))
                            guard
                                let appStep = emissions.last as? AppStep,
                                case let AppStep.alert(receivedAlertDetails) = appStep,
                                receivedAlertDetails == expectedAlertDetails
                            else {
                                fail("""
                                    Expected to get AppStep.alert(\(expectedAlertDetails)), \
                                    got: \(String(describing: emissions.last))
                                    """)
                                return
                            }
                        }).disposed(by: disposeBag)
                }

                it("continues listening to search requests") {
                    sut.searchText.accept("a")

                    mockSearchService.stubbedSearchResult = .just(([], URL(string: "")))

                    sut.searchText.accept("aa")

                    expect(mockSearchService.invokedSearchCount).to(equal(2))
                }
            }
        }
    }
}

extension SearchViewModelSpec {
    
    class TestAssembly: Assembly {

        func assemble(container: Container) {
            container.register(SearchViewModel.self) { _ in
                let instance = SearchViewModel()
                return instance
            }.inObjectScope(.transient)

            container.register(SearchServiceProtocol.self) { _ in
                return MockSearchService()
            }.inObjectScope(.container)
        }
    }
}
