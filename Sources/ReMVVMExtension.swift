//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

public enum ReMVVMExtension {

    public static func initialize<State>(with state: State,
                                         stateMappers: [StateMapper<State>] = [],
                                         reducer: AnyReducer<State>,
                                         middleware: [AnyMiddleware] = []) -> Store<AppNavigationState<State>> {

        let reducer = AnyReducer { state, action -> AppNavigationState<State> in
            return AppNavigationState<State>(
                appState: reducer.reduce(state: state.appState, with: action),
                navigation: NavigationReducer.reduce(state: state.navigation, with: action)
            )
        }

        let mappers: [StateMapper<AppNavigationState<State>>] = [
            StateMapper(for: \.appState),
            StateMapper(for: \.navigation)
        ]

        let stateMappers = mappers + stateMappers.map { $0.map(with: \.appState) }

        return self.initialize(with: AppNavigationState(appState: state),
                               stateMappers: stateMappers,
                               reducer: reducer,
                               middleware: middleware)
    }

    public static func initialize<State: NavigationState>(with state: State,
                                                          stateMappers: [StateMapper<State>] = [],
                                                          reducer: AnyReducer<State>,
                                                          middleware: [AnyMiddleware] = []) -> Store<State> {

        let store = Store<State>(with: state,
                                 reducer: reducer,
                                 middleware: middleware,
                                 stateMappers: stateMappers)

        ReMVVM.initialize(with: store)
        return store
    }
}
