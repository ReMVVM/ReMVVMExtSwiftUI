//
//  NavigationReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

public enum NavigationReducer {

    static let reducer = AnyReducer(with: [PushReducer.any,
                                           PopReducer.any,
                                           ShowReducer.any,
                                           ShowModalReducer.any,
                                           DismissModalReducer.any,
                                           SynchronizeReducer.any])

    public static func reduce(state: Navigation, with action: StoreAction) -> Navigation {
        return reducer.reduce(state: state, with: action)
    }
}
