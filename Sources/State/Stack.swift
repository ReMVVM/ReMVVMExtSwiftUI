//
//  Stack.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVM
import SwiftUI

extension UUID: Identifiable, Initializable {
    public var id: UUID { self }
}

public struct Stack<StackItem> where StackItem: Identifiable, StackItem.ID: Initializable {

    public let id: StackItem.ID
    public let items: [StackItem]

    public init(with items: [StackItem] = [], id: StackItem.ID = .init()) {
        self.items = items
        self.id = id
    }

    public func item(with id: StackItem.ID) -> StackItem? {
        guard let index = items.firstIndex(where: { $0.id == id }) else  { return nil }
        return items[index]
    }

    public func nextId(for id: StackItem.ID) -> StackItem.ID? {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return nil }
        guard index + 1 < items.count else { return self.id }
        return items[index + 1].id
    }

    public func nextItem(for id: StackItem.ID) -> StackItem? {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return nil }
        guard index + 1 < items.count else { return nil }
        return items[index + 1]
    }
}
