//
//  NavigationState.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore

public protocol NavigationState: StoreState {
    var navigation: Navigation { get }
}
