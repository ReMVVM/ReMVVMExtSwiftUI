//
//  Navigation.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 06/09/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVM
import SwiftUI

public struct Navigation {
    public let modals: Stack<Modal>
    public let root: Root

    public init(root: Root, modals: Stack<Modal> = Stack()) {
        self.root = root
        self.modals = modals
    }

    public var viewModelFactory: ViewModelFactory {
        return modals.viewModelFactory ?? root.viewModelFactory ?? CompositeViewModelFactory()
    }

    public func item(with id: UUID) -> Element? {
        if let element = root.element(for: id) {
            return element
        }

        //TODO move to stack extension where Modal ?
        for modal in modals.items {
            if let element = modal.item(with: id) {
                return element
            }
        }

        return nil
    }

    public func nextId(for id: UUID) -> UUID? {
        if let nextId = root.nextId(for: id) {
            return nextId
        }

        //TODO move to stack extension where Modal ?
        for modal in modals.items {
            if let nextId = modal.nextId(for: id) {
                return nextId
            }
        }
        return nil
    }

    public func nextItem(for id: UUID) -> Element? {
        if let item = root.nextItem(for: id) {
            return item
        }

        //TODO move to stack extension where Modal ?
        for modal in modals.items {
            if let item = modal.nextItem(for: id) {
                return item
            }
        }

        return nil
    }

    public static let root = RootNavigationItem.item
}

extension Stack where StackItem == Modal {
    var viewModelFactory: ViewModelFactory? {
        return items.last?.viewModelFactory
    }
}

extension Stack where StackItem == Element {
    var viewModelFactory: ViewModelFactory? {
        return items.last?.viewModelFactory
    }
}
