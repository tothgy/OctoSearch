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
    
    public static var instance: MainAssembler! = nil

    var resolver: Resolver {
        return assembler.resolver
    }

    let container: Container
    private let assembler: Assembler
    
    // swiftlint:disable force_cast
    private init(withAssembly assembly: Assembly) {
        container = SwinjectStoryboard.defaultContainer
        assembler = Assembler(container: container)
        assembler.apply(assembly: assembly)
    }
    
    static func create(withAssembly assembly: Assembly) -> MainAssembler {
        instance = MainAssembler(withAssembly: assembly)
        return instance
    }

    func dispose() {
        SwinjectStoryboard.defaultContainer.removeAll()
    }
}

class MainAssembly: Assembly {

    func assemble(container: Container) {
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
