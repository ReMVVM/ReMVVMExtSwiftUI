//
//  Modal.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVM
import SwiftUI

public enum Modal: Identifiable {

    case single(Element)
    case navigation(Stack<Element>)

    public var viewModelFactory: ViewModelFactory? {
        switch self {
        case .single(let item): return item.viewModelFactory
        case .navigation(let stack): return stack.items.last?.viewModelFactory
        }
    }

    public var hasNavigation: Bool {
        guard case .navigation = self else { return false }
        return true
    }

    public var id: UUID {
        switch self {
        case .single(let item): return item.id
        case .navigation(let stack): return stack.items.first?.id ?? stack.id // todo
        }
    }

    public func item(with id: UUID) -> Element? {
        switch self {
        case .single(let item): return item.id == id ? item : nil
        case .navigation(let stack): return stack.item(with: id)
        }
    }

    public func nextId(for id: UUID) -> UUID? {
        switch self {
        case .single: return nil
        case .navigation(let stack): return stack.nextId(for: id)
        }
    }

    public func nextItem(for id: UUID) -> Element? {
        switch self {
        case .single: return nil
        case .navigation(let stack): return stack.nextItem(for: id)
        }
    }
}
