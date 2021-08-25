//
//  File.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

private enum AppNavigationReducer<State, R>: Reducer where R: Reducer, R.State == State, R.Action == StoreAction {

    static func reduce(state: AppNavigationState<State>, with action: StoreAction) -> AppNavigationState<State> {
        AppNavigationState<State>(
            appState: R.reduce(state: state.appState, with: action),
            navigation: NavigationReducer.reduce(state: state.navigation, with: action)
        )
    }
}

//todo rename to ReMVVM 
public enum ReMVVMExtension {

    public static func initialize<State, R>(with state: State,
                                         stateMappers: [StateMapper<State>] = [],
                                         reducer: R.Type,
                                         middleware: [AnyMiddleware] = []) -> Store<AppNavigationState<State>>
    where R: Reducer, R.Action == StoreAction, R.State == State {

        let mappers: [StateMapper<AppNavigationState<State>>] = [
            StateMapper(for: \.appState),
            StateMapper(for: \.navigation)
        ]

        let stateMappers = mappers + stateMappers.map { $0.map(with: \.appState) }

        return self.initialize(with: AppNavigationState(appState: state),
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
