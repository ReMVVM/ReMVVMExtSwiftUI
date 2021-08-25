//
//  TabNavigationItem.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import SwiftUI
import ReMVVMCore

public typealias HashableTabNavigationItem = TabNavigationItem & Hashable

public protocol TabNavigationItem: NavigationItem {
    var action: StoreAction { get }
    var tabItemFactory: ViewFactory { get }

    var tabViewFactory: ViewFactory { get }
    var viewModelFactory: ViewModelFactory? { get }
}

extension TabNavigationItem where Self: CaseIterableNavigationItem  {
    public var action: StoreAction { Show(on: self, view: tabViewFactory()) }
    public var viewModelFactory: ViewModelFactory? { nil }
    public var title: String? { nil }
    public var icon: Image? { nil }

    public static var viewFactory: ViewFactory {
        { TabContainerView().any }
    }
}
