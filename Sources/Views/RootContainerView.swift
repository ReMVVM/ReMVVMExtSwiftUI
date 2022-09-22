//
//  RootContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import SwiftUI
import ReMVVMSwiftUI

public struct RootContainerView: View {

    @ReMVVM.State private var state: Navigation?

    private var id: UUID { state?.root.currentStack.items.first?.id ?? state?.root.currentStack.id ?? UUID() }

    public init() { }

    public var body: some View {
        NavigationView {
            ContainerView(id: id, synchronize: false)
        }
    }
}
