//
//  View+AnyView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import SwiftUI

extension View {
    public var any: AnyView { return AnyView(self) }
}
