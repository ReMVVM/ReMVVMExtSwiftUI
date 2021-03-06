//
//  RootNavigationItem.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore
import SwiftUI

public struct RootNavigationItem: CaseIterableNavigationItem {
    private init() { }
    
    public static var viewFactory: ViewFactory {
        { RootContainerView().any }
    }

    public static var item = RootNavigationItem()

    public static var allCases: [RootNavigationItem] = [item]
}
