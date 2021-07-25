//
//  Inject.swift
//  OctoSearch
//

import Foundation
import Swinject

@propertyWrapper
public struct Inject<Component> {
    private var component: Component
    
    public init() {
        component = MainAssembler.shared.container.get(Component.self)
    }
    
    public var wrappedValue: Component {
        get { return component}
        mutating set { component = newValue }
    }
}
