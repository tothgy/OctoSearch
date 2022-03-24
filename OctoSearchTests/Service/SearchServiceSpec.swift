//
//  SearchServiceSpec.swift
//  OctoSearch
//

@testable import OctoSearch
import Nimble
import Quick
import RxSwift
import Swinject
import Moya
import InjectPropertyWrapper

// swiftlint:disable file_length function_body_length
class SearchServiceSpec: QuickSpec {

    override func spec() {
        describe("SearchService") {
            var sut: SearchService!
            var assembler: MainAssembler!
            var disposeBag: DisposeBag!

            beforeEach {
                assembler = MainAssembler.create(withAssembly: TestAssembly())
                InjectSettings.resolver = assembler.container

                let container = assembler.container
                sut = container.resolve(SearchService.self)
                disposeBag = DisposeBag()
            }
            
            afterEach {
                disposeBag = nil
            }

            describe("search") {
                it("makes a network request with the given search text") {
                    sut.search("repo").subscribe().disposed(by: disposeBag)

                    expect(searchParameterQ).to(equal("repo"))
                }

                context("when request succeeds") {
                    beforeEach {
                        expectedSearchResponse = StubSearchSucessResponse.successResponse
                    }

                    it("emits the retrieved Repositories") {
                        let successExpectation = QuickSpec.current.expectation(description: "success")

                        sut.search("repo")
                            .subscribe(onSuccess: { (repositories: [Repository], _) in
                                successExpectation.fulfill()
                                expect(repositories).to(haveCount(1))
                            })
                            .disposed(by: disposeBag)

                        QuickSpec.current.waitForExpectations(timeout: 1)
                    }
                }

                context("when the request fails") {
                    beforeEach {
                        expectedSearchResponse = .networkResponse(503, Data())
                    }

                    it("emits the error") {
                        var receivedError: Error?

                        sut.search("repo")
                            .subscribe(onError: { (error: Error) in
                                receivedError = error
                            })
                            .disposed(by: disposeBag)

                        expect(receivedError).toNot(beNil())
                    }
                }
            }
        }
    }
}

private var searchParameterQ: String?
private var expectedSearchResponse: EndpointSampleResponse = .networkResponse(200, Data())

extension SearchServiceSpec {
    
    class TestAssembly: Assembly {

        func assemble(container: Container) {
            container.register(SearchService.self) { _ in
                let instance = SearchService()
                return instance
            }.inObjectScope(.transient)

            container.register(MoyaProvider<GitHubApi>.self) { _ in
                return MoyaProvider<GitHubApi>(
                    endpointClosure: self.createStubEndpoint,
                    stubClosure: MoyaProvider.immediatelyStub,
                    plugins: [NetworkLoggerPlugin()])
            }.inObjectScope(.container)
        }

        func createStubEndpoint(withTarget target: GitHubApi) -> Endpoint {
            var sampleResponseClosure: Endpoint.SampleResponseClosure
            switch target {
            case let .searchRepositories(query):
                searchParameterQ = query
                sampleResponseClosure = { expectedSearchResponse }
            case .nextSearchPage:
                sampleResponseClosure = { expectedSearchResponse }
            }

            return Endpoint(
                url: url(target),
                sampleResponseClosure: sampleResponseClosure,
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers)
        }
    }
}
