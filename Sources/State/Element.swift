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
    public var viewFactory: ViewFactory { container.viewFactory }
    public var view: AnyView { container.view }
    public var popup: AnyView? { container.popup }

    public let modalPresentationStyle: ShowModal.PresentationStyle?

    private let container: ViewContainer

    private final class ViewContainer {
        let viewFactory: ViewFactory
        let popupFactory: ViewFactory?

        lazy var view: AnyView =  { viewFactory() }()
        lazy var popup: AnyView? = { popupFactory?() }()

        init(_ viewFactory: @escaping ViewFactory, popupFactory: ViewFactory?) {
            self.viewFactory = viewFactory
            self.popupFactory = popupFactory
        }
    }

    public init(with id: UUID,
                viewFactory: @escaping ViewFactory,
                factory: ViewModelFactory,
                modalPresentationStyle: ShowModal.PresentationStyle? = nil,
                popupFactory: ViewFactory? = nil) {
        self.id = id
        self.viewModelFactory = factory
        self.container = ViewContainer(viewFactory, popupFactory: popupFactory)
        self.modalPresentationStyle = modalPresentationStyle
    }
}
