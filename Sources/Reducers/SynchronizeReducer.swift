//
//  SynchronizeReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public enum SynchronizeReducer: Reducer {
    public static func reduce(state: Navigation, with action: Synchronize) -> Navigation {
        if let modal = state.modals.items.last, modal.id == action.viewID { // modal swiped down
            return Navigation(root: state.root, modals: state.modals.dropLast(1))
        }

        let stack: Stack<Element>
        if case .navigation(let navigationStack) = state.modals.items.last {
            stack = navigationStack
        } else {
            stack = state.root.currentStack
        }

        if let index = stack.items.lastIndex(where: { $0.id == action.viewID }), index == stack.items.count - 1 {
            return state.pop(1) // TODO: What is going on here??
        }

        return state
    }
}
