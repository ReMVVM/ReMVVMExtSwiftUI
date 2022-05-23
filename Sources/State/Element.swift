//
//  Item.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Foundation
import ReMVVMCore
import SwiftUI

public struct Element: Identifiable {
    public let id: UUID
    public let viewModelFactory: ViewModelFactory
    //public var viewFactory: ViewFactory { container.viewFactory }
    public var view: AnyView { container.view }

    public let modalPresentationStyle: ShowModal.PresentationStyle?

    private let container: ViewContainer
    private final class ViewContainer {
        let viewFactory: ViewFactory
        lazy var view: AnyView =  { viewFactory() }()
        init(_ viewFactory: @escaping ViewFactory) {
            self.viewFactory = viewFactory
        }
    }

    public init(with id: UUID, viewFactory: @escaping ViewFactory, factory: ViewModelFactory, modalPresentationStyle: ShowModal.PresentationStyle? = nil) {
        self.id = id
        self.viewModelFactory = factory
        self.container = ViewContainer(viewFactory)
        self.modalPresentationStyle = modalPresentationStyle
    }
}
