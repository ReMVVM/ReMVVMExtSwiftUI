//
//  PushReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM
import SwiftUI

public enum PushReducer: Reducer {

    public static func reduce(state: Navigation, with action: NavigationActions.Push) -> Navigation  {
        state.push(viewFactory: action.viewFactory, factory: action.factory)
    }
}

extension Navigation {

    func push(viewFactory: @escaping () -> AnyView, factory: ViewModelFactory?) -> Navigation {
        let factory = factory ?? viewModelFactory
        if modals.hasNavigation {
            return Navigation(root: root, modals: modals.push(viewFactory: viewFactory, factory: factory))
        } else {
            return Navigation(root: root.push(viewFactory: viewFactory, factory: factory))
        }
    }
}

extension Stack where StackItem == Modal {

    func push(viewFactory: @escaping () -> AnyView, factory: ViewModelFactory) -> Self {
        let items = self.items.reversed().drop { !$0.hasNavigation }.reversed()
        if case .navigation(let stack) = items.last {
            let newStack = stack.push(viewFactory: viewFactory, factory: factory)
            let newItems = Array(items.dropLast()) + [.navigation(newStack)]
            return Stack(with: newItems)
        } else {
            let stack = Stack<Element>(with: [Element(with: id, viewFactory: viewFactory, factory: factory)])
            return Stack(with: [.navigation(stack)])
        }
    }
}

extension Root {

    func push(viewFactory: @escaping () -> AnyView, factory: ViewModelFactory) -> Root {
        let stacks = self.stacks.enumerated().map { index, stack -> (NavigationItem, Stack<Element>) in
            guard index == current else { return stack }
            return (stack.0, stack.1.push(viewFactory: viewFactory, factory: factory))
        }
        return Root(current: current, stacks: stacks)
    }
}

extension Stack where StackItem == Element {

    func push(viewFactory: @escaping () -> AnyView, factory: ViewModelFactory) -> Self {
        let item = Element(with: id, viewFactory: viewFactory, factory: factory)
        return Stack(with: items + [item])
    }
}

