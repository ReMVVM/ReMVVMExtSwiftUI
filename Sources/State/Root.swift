//
//  Root.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVMCore
import SwiftUI

public struct Root {

    public let current: Int
    public let stacks: [(NavigationItem, Stack<Element>)]

    public var currentItem: NavigationItem { stacks[current].0 }
    public var currentStack: Stack<Element> { stacks[current].1 }

    public var viewModelFactory: ViewModelFactory? { currentStack.viewModelFactory }
    //public func currentItem<T>(of type: T.Type) -> T? { currentItem.base as? T }

    public init(stack: Stack<Element>) {
        self.init(current: 0, stacks: [(Navigation.root, stack)])
    }

    public init<T>(current: Int, stacks: [(T, Stack<Element>)]) where T: CaseIterableNavigationItem {
        if !stacks.isEmpty {
            self.init(stack: Stack())
        } else {
            self.init(current: current, stacks: stacks.map { ($0, $1) })
        }
    }

    init(current: Int, stacks: [(NavigationItem, Stack<Element>)]) {

        if current < 0 {
            self.current = 0
        } else if current >= stacks.count {
            self.current = stacks.count - 1
        } else {
            self.current = current
        }

        self.stacks = stacks
    }

    public func element(for id: UUID) -> Element? {
        for stack in stacks {
            if let element = stack.1.item(with: id) {
                return element
            }
        }
        return nil
    }

    public func nextId(for id: UUID) -> UUID? {
        for stack in stacks {
            if let next = stack.1.nextId(for: id) {
                return next
            }
        }
        return nil
    }

    public func nextItem(for id: UUID) -> Element? {
        for stack in stacks {
            if let element = stack.1.nextItem(for: id) {
                return element
            }
        }
        return nil
    }
}
