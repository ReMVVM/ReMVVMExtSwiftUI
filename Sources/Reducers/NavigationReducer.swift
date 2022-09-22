//
//  NavigationReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public enum NavigationReducer: Reducer {
    static let composed = PushReducer
        .compose(with: PopReducer.self)
        .compose(with: ShowReducer.self)
        .compose(with: ShowModalReducer.self)
        .compose(with: DismissModalReducer.self)
        .compose(with: SynchronizeReducer.self)

    public static func reduce(state: Navigation, with action: StoreAction) -> Navigation {
        composed.reduce(state: state, with: action)
    }
}
