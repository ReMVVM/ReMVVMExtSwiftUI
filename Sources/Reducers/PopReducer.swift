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
        switch action.mode {
        case .pop(let count): return state.pop(count)
        case .popToRoot: return state.popToRoot()
        }
    }
}

extension Navigation {
    func pop(_ count: Int) -> Navigation {
        if modals.hasNavigation {
            return Navigation(root: root, modals: modals.pop(count))
        } else {
            return Navigation(root: root.pop(count))
        }
    }

    func popToRoot() -> Navigation {
        if modals.hasNavigation {
            return Navigation(root: root, modals: modals.popToRoot())
        } else {
            return Navigation(root: root.popToRoot())
        }
    }
}

extension Stack where StackItem == Modal {

    var hasNavigation: Bool { items.contains { $0.hasNavigation } }

    func pop(_ count: Int) -> Self {
        guard hasNavigation else { return self }
        let items = self.items.reversed().drop { !$0.hasNavigation }.reversed()
        guard case .navigation(let stack) = items.last else { return self }
        let newItems = Array(items.dropLast()) + [.navigation(stack.pop(count))]
        return Stack(with: newItems)
    }

    func popToRoot() -> Self {
        guard hasNavigation else { return self }
        let items = self.items.reversed().drop { !$0.hasNavigation }.reversed()
        guard case .navigation(let stack) = items.last else { return self }
        let newItems = Array(items.dropLast()) + [.navigation(stack.popToRoot())]
        return Stack(with: newItems)
    }
}

extension Root {
    func pop(_ count: Int) -> Root {
        let stacks = self.stacks.enumerated().map { index, stack -> (NavigationItem, Stack<Element>) in
            guard index == current else { return stack }
            return (stack.0, stack.1.pop(count))
        }
        return Root(current: current, stacks: stacks)
    }

    func popToRoot() -> Root {
        let stacks = self.stacks.enumerated().map { index, stack -> (NavigationItem, Stack<Element>) in
            guard index == current else { return stack }
            return (stack.0, stack.1.popToRoot())
        }
        return Root(current: current, stacks: stacks)
    }
}

extension Stack where StackItem == Element {
    func pop(_ count: Int) -> Self {
        guard items.count > 1 else { return self }
        guard items.count > count else { return Stack(with: items.dropLast(items.count - 1)) }
        return Stack(with: items.dropLast(count))
    }

//    func empty() -> Self {
//        guard items.count > 0 else { return self }
//        return Stack(id: items[0].id)
//    }

    func popToRoot() -> Self {
        guard items.count > 1 else { return self }
        return Stack(with: [items[0]])
    }
}
