//
//  ShowReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public enum ShowReducer: Reducer {
    public static func reduce(state: Navigation, with action: Show) -> Navigation {
        let current = action.item
        var stacks: [(NavigationItem, Stack<Element>)]
        let factory = action.factory ?? state.viewModelFactory
        if !action.item.isType(of: RootNavigationItem.self) && action.item.isEqualType(to: state.root.currentItem) {
            stacks = state.root.stacks.map {
                guard $0.0.isEqual(to: current), $0.1.items.isEmpty else { return $0 }
                return ($0.0, $0.1.push(viewFactory: action.viewFactory, factory: factory))
            }
        } else {
            stacks = type(of: action.item).allItems.map {
                let stack = Stack<Element>()
                guard $0.isEqual(to: current) else { return ($0,stack) }
                return ($0, stack.push(viewFactory: action.viewFactory, factory: factory))
            }
        }
        let index = stacks.firstIndex { $0.0.isEqual(to: current) } ?? 0
        return Navigation(root: Root(current: index, stacks: stacks))
    }
}
