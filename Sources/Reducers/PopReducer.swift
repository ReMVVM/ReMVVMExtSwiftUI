//
//  PopReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public enum PopReducer: Reducer {
    public static func reduce(state: Navigation, with action: Pop) -> Navigation  {
        state.pop()
    }
}

extension Navigation {

    func pop() -> Navigation {
        if modals.hasNavigation {
            return Navigation(root: root, modals: modals.pop())
        } else {
            return Navigation(root: root.pop())
        }
    }
}

extension Stack where StackItem == Modal {

    var hasNavigation: Bool { items.contains { $0.hasNavigation } }

    func pop() -> Self {
        guard hasNavigation else { return self }
        let items = self.items.reversed().drop { !$0.hasNavigation }.reversed()
        guard case .navigation(let stack) = items.last else { return self }
        let newItems = Array(items.dropLast()) + [.navigation(stack.pop())]
        return Stack(with: newItems)
    }
}

extension Root {

    func pop() -> Root {
        let stacks = self.stacks.enumerated().map { index, stack -> (NavigationItem, Stack<Element>) in
            guard index == current else { return stack }
            return (stack.0, stack.1.pop())
        }
        return Root(current: current, stacks: stacks)
    }
}

extension Stack where StackItem == Element {

    func pop() -> Self {
        guard items.count > 1 else { return self }
        return Stack(with: items.dropLast())
    }

    func empty() -> Self {
        guard items.count > 0 else { return self }
        return Stack(id: items[0].id)
    }

//    func popToRoot() -> Self {
//        guard items.count > 1 else { return self }
//        return Stack(with: [items[0]])
//    }
}
