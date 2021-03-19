//
//  SynchronizeReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

public enum SynchronizeReducer: Reducer {
    public static func reduce(state: Navigation, with action: Synchronize) -> Navigation  {

        if let modal = state.modals.items.last, modal.id == action.viewID { //modal swiped down
            return Navigation(root: state.root, modals: state.modals.dropLast())
        }

        let stack: Stack<Element>
        if case .navigation(let s) = state.modals.items.last {
            stack = s
        } else {
            stack = state.root.currentStack
        }

        if let index = stack.items.lastIndex(where: { $0.id == action.viewID }), index == stack.items.count - 1 {
            return state.pop()
        }

        return state
    }
}

