//
//  ApplicationAssembly.swift
//  OctoSearch
//

import Foundation
import Swinject
import Alamofire

class ApplicationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ETitanStoreProtocol.self) { _ in
            return ETitanStore()
        }.inObjectScope(.container)
        
        container.register(UserStoreProtocol.self) { _ in
            return UserStore()
        }.inObjectScope(.container)
        
        container.register(UserRepositoryProtocol.self) { _ in
            return UserRepository()
        }.inObjectScope(.container)
    }
}
