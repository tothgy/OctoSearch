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

// swiftlint:disable file_length
class SearchViewModelSpec: QuickSpec {

    // swiftlint:disable function_body_length
    override func spec() {
        describe("SearchViewModel") {
            var sut: SearchViewModel!
            var mockSearchService: MockSearchService!
            var disposeBag: DisposeBag!

            beforeEach {
                MainAssembler.shared.create(with: TestAssembly())

                let container = MainAssembler.shared.container
                sut = container.resolve(SearchViewModel.self)
                mockSearchService = container.resolve(SearchServiceProtocol.self) as? MockSearchService
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            describe("cells$") {
                context("""
                    given that a search text has been published \
                    and the Search Services returned a list of Repositories
                    """) {
                    var expectedRepository: Repository!

                    beforeEach {
                        expectedRepository = .init(
                            id: 1,
                            name: "Repo-1",
                            fullName: "Repository 1",
                            htmlUrl: "https://github.com/repo",
                            repositoryDescription: "Repo description")

                        mockSearchService.stubbedSearchResult = .just([
                            expectedRepository
                        ])
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
                                expect(emissions).to(haveCount(1))
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
                                expect(emissions).to(haveCount(1))
                                let cellModels = emissions.last!
                                expect(cellModels).to(haveCount(1))
                                let cellModel = cellModels.last!
                                expect(cellModel.subtitle).to(equal(expectedRepository.repositoryDescription))
                            }).disposed(by: disposeBag)
                    }
                }
            }
        }
    }
}

extension SearchViewModelSpec {
    
    class TestAssembly: MainAssemblyProtocol {
        var container: Container = .init()

        func assemble() {
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
