//
//  MainAssemblyProtocol.swift
//  OctoSearch
//

import Foundation
import Swinject
import SwinjectStoryboard

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
    }
}
