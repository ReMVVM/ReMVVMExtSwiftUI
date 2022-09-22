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
        (navigation.viewModelFactory as? CompositeViewModelFactory) ?? .init(with: navigation.viewModelFactory)
    }

    public init(appState: State,
                navigation: Navigation = Navigation(root: Root(stack: Stack())),
                uiConfig: UIStateConfig) {
        self.appState = appState
        self.navigation = navigation
        self.uiConfig = uiConfig
    }
}
