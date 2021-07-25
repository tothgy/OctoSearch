//
//  MockMultiTargetApiProvider.swift
//  OctoSearchTests
//

@testable import OctoSearch
import Quick
import Nimble
import Moya

class SampleEndpointResponseProvider {
    lazy var moyaProvider: MoyaProvider<MultiTarget> = {
        return MoyaProvider<MultiTarget>(
            endpointClosure: self.createStubEndpoint,
            stubClosure: MoyaProvider.immediatelyStub,
            plugins: [NetworkLoggerPlugin()])
    }()

    private var sampleResponses: [EndpointSampleResponse]?

    func expectSampleResponses(_ responses: [EndpointSampleResponse]) {
        sampleResponses = responses
    }

    func createStubEndpoint(withTarget target: MultiTarget) -> Endpoint {
        var sampleResponseClosure: Endpoint.SampleResponseClosure
        sampleResponseClosure = {
            self.getNextSampleResponse()
        }
        return Endpoint(
            url: url(target),
            sampleResponseClosure: sampleResponseClosure,
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers)
    }

    private func getNextSampleResponse() -> EndpointSampleResponse {
        return sampleResponses!.remove(at: 0)
    }
}
