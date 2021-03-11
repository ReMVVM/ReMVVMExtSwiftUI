//
//  NavigationItem.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import SwiftUI

public protocol NavigationItem {
    static var viewFactory: () -> AnyView { get }
    static var allItems: [NavigationItem] { get }

    func isEqual(to: NavigationItem) -> Bool
    func isEqualType(to: NavigationItem) -> Bool
    func isType<T>(of: T.Type) -> Bool
}

extension NavigationItem {
    public func isEqualType(to item: NavigationItem) -> Bool { type(of: self) == type(of: item) }
    public func isType<T>(of: T.Type) -> Bool { type(of: self) == T.self }
}

extension NavigationItem where Self: CaseIterable {
    public static var allItems: [NavigationItem] { allCases.map { $0 } }
}

extension NavigationItem where Self: Equatable {
    public func isEqual(to item: NavigationItem) -> Bool {
        return (item as? Self) == self
    }
}

public typealias CaseIterableNavigationItem = NavigationItem & CaseIterable & Hashable
