//
//  Item.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVM
import SwiftUI

public struct Element: Identifiable {

    public let id: UUID
    public let viewModelFactory: ViewModelFactory
    //public var viewFactory: () -> AnyView { container.viewFactory }
    public var view: AnyView { container.view }

    private let container: ViewContainer
    private final class ViewContainer {
        let viewFactory: () -> AnyView
        lazy var view: AnyView =  { viewFactory() }()
        init(_ viewFactory: @escaping () -> AnyView) {
            self.viewFactory = viewFactory
        }
    }

    public init(with id: UUID, viewFactory: @escaping () -> AnyView, factory: ViewModelFactory) {
        self.id = id
        self.viewModelFactory = factory
        self.container = ViewContainer(viewFactory)
    }
}
