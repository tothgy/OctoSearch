//
//  MainAssemblyProtocol.swift
//  OctoSearch
//

import Foundation
import RxSwift
import Swinject
import SwinjectStoryboard
import Moya

class MainAssembler {
    
    public static let shared = MainAssembler()
    public private (set) var container: Container = SwinjectStoryboard.defaultContainer
    
    private init() {}
    
    func create(with assembly: MainAssemblyProtocol) {
        removeAll()
        self.container = assembly.container
        assembly.assemble()
    }
    
    func removeAll() {
        container.removeAll()
    }
}

protocol MainAssemblyProtocol {
    var container: Container { get }
    func assemble()
}

class MainAssembly: MainAssemblyProtocol {
    let container: Container = Container()
    
    func assemble() {
        container.register(SearchViewModelProtocol.self) { _ in
            return SearchViewModel()
        }.inObjectScope(.transient)

        container.register(SchedulerType.self) { _ in
            return MainScheduler.instance
        }.inObjectScope(.container)

        container.register(SearchServiceProtocol.self) { _ in
            return SearchService()
        }.inObjectScope(.transient)

        container.register(MoyaProvider<GitHubApi>.self) { _ in
            return MoyaProvider<GitHubApi>(
                plugins: [NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))])
        }.inObjectScope(.container)
    }
}
