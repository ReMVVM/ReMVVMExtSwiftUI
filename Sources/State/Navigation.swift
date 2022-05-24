//
//  Navigation.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 06/09/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVMCore
import SwiftUI

public struct Navigation {
    public let modals: Stack<Modal>
    public let root: Root

    public init(root: Root, modals: Stack<Modal> = Stack()) {
        self.root = root
        self.modals = modals
    }

    public var viewModelFactory: ViewModelFactory {
        modals.viewModelFactory ?? root.viewModelFactory ?? CompositeViewModelFactory()
    }

    public func item(with id: UUID) -> Element? {
        if let element = root.element(for: id) {
            return element
        }

        if let element = modals.element(with: id) {
            return element
        }

        return nil
    }

    public func nextId(for id: UUID) -> UUID? {
        if let nextId = root.nextId(for: id) {
            return nextId
        }

        if let nextId = modals.nextId(for: id) {
            return nextId
        }

        return nil
    }

    public func nextItem(for id: UUID) -> Element? {
        if let item = root.nextItem(for: id) {
            return item
        }

        if let item = modals.nextElement(with: id) {
            return item
        }

        return nil
    }

    public static let root = RootNavigationItem.item
}

extension Stack where StackItem == Modal {
    var viewModelFactory: ViewModelFactory? {
        items.last?.viewModelFactory
    }

    func element(with id: UUID) -> Element? {
        for modal in items {
            if let element = modal.item(with: id) {
                return element
            }
        }
        return nil
    }

    func nextElement(with id: UUID) -> Element? {
        for modal in items {
            if let item = modal.nextItem(for: id) {
                return item
            }
        }

        return nil
    }

    func nextId(for id: UUID) -> UUID? {
        for modal in items {
            if let nextId = modal.nextId(for: id) {
                return nextId
            }
        }

        return nil
    }
}

extension Stack where StackItem == Element {
    var viewModelFactory: ViewModelFactory? {
        items.last?.viewModelFactory
    }
}
