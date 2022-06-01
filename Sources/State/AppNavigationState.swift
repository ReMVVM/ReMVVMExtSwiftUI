//
//  AppNavigationState.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public struct AppNavigationState<State>: NavigationState {
    public let navigation: Navigation
    public let uiConfig: UIStateConfig

    public let appState: State

    public var factory: ViewModelFactory {
        let factory: CompositeViewModelFactory
        if let f = navigation.viewModelFactory as? CompositeViewModelFactory {
            factory = f
        } else {
            factory = CompositeViewModelFactory(with: navigation.viewModelFactory)
        }

        return factory
    }

    public init(appState: State,
                navigation: Navigation = Navigation(root: Root(stack: Stack())),
                uiConfig: UIStateConfig) {
        self.appState = appState
        self.navigation = navigation
        self.uiConfig = uiConfig
    }
}
