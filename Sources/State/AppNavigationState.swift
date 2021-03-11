//
//  AppNavigationState.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

public struct AppNavigationState<State>: NavigationState {

    public let navigation: Navigation

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
                navigation: Navigation = Navigation(root: Root(stack: Stack()))) {
        self.appState = appState
        self.navigation = navigation
    }
}
