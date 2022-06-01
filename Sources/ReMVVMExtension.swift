//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore
import SwiftUI

private enum AppNavigationReducer<State, R>: Reducer where R: Reducer, R.State == State, R.Action == StoreAction {
    static func reduce(state: AppNavigationState<State>, with action: StoreAction) -> AppNavigationState<State> {
        AppNavigationState<State>(appState: R.reduce(state: state.appState, with: action),
                                  navigation: NavigationReducer.reduce(state: state.navigation, with: action),
                                  uiConfig: state.uiConfig)
    }
}

extension ReMVVM {
    public static func initialize<State, R>(with state: State,
                                            stateMappers: [StateMapper<State>] = [],
                                            uiStateConfig: UIStateConfig,
                                            reducer: R.Type,
                                            middleware: [AnyMiddleware] = []) -> Store<AppNavigationState<State>>
    where R: Reducer, R.Action == StoreAction, R.State == State {

        let mappers: [StateMapper<AppNavigationState<State>>] = [
            StateMapper(for: \.appState),
            StateMapper(for: \.navigation),
            StateMapper(for: \.uiConfig)
        ]

        let stateMappers = mappers + stateMappers.map { $0.map(with: \.appState) }

        return self.initialize(with: AppNavigationState(appState: state, uiConfig: uiStateConfig),
                               stateMappers: stateMappers,
                               reducer: AppNavigationReducer<State, R>.self,
                               middleware: middleware)
    }

    public static func initialize<State, R>(with state: State,
                                            stateMappers: [StateMapper<State>] = [],
                                            reducer: R.Type,
                                            middleware: [AnyMiddleware] = []) -> Store<State>
    where State: NavigationState, R: Reducer, R.Action == StoreAction, R.State == State {

        let store = Store<State>(with: state,
                                 reducer: reducer,
                                 middleware: middleware,
                                 stateMappers: stateMappers)

        //ReMVVM.initialize(with: store)
        return store
    }
}


public struct UIStateConfig {
    //let initialController: () -> UIViewController
    //let navigationController: () -> UINavigationController
    let navigationConfigs: NavigationConfig
    //let navigationBarHidden: Bool

    public init(//initialController: @escaping @autoclosure () -> UIViewController,
                //navigationController: (() -> UINavigationController)? = nil,
                navigationConfigs: NavigationConfig
                //navigationBarHidden: Bool = true
                ) {
        //self.initialController = initialController
        //self.navigationController = navigationController ?? { UINavigationController() }
        self.navigationConfigs = navigationConfigs
        //self.navigationBarHidden = navigationBarHidden
    }
}

public struct NavigationConfig {
    public typealias TabBarFactory = (_ items: [AnyView], _ selectedIndex: Binding<Int>) -> AnyView

    public var tabBarFactory: TabBarFactory

    public init(tabBarFactory: @escaping TabBarFactory) {
        self.tabBarFactory = tabBarFactory
    }
}
