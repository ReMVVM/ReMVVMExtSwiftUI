//
//  NavigationActions.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore
import SwiftUI

public typealias ViewFactory = () -> AnyView

public struct Push: StoreAction {
    public let viewFactory: ViewFactory
    public let factory: ViewModelFactory?

    public init<V>(with view: @autoclosure @escaping () -> V, factory: ViewModelFactory? = nil) where V: View {
        self.viewFactory = { AnyView(view()) }
        self.factory = factory
    }
}

public struct Pop: StoreAction {
    public enum PopMode {
        case popToRoot, pop(Int)
    }

    public let animated: Bool
    public let mode: PopMode
    public init(mode: PopMode = .pop(1), animated: Bool = true) {
        self.mode = mode
        self.animated = animated
    }
}

public struct Show: StoreAction {
    public let viewFactory: ViewFactory
    public let factory: ViewModelFactory?
    public let item: NavigationItem

    public init<N,V>(on navigationItem: N,
                     view: @autoclosure @escaping () -> V,
                     factory: ViewModelFactory? = nil,
                     animated: Bool = true, // TODO
                     navigationBarHidden: Bool = true) // TODO
        where N: CaseIterableNavigationItem, V: View {

            self.viewFactory = { AnyView(view()) }
            self.factory = factory
            self.item = navigationItem
    }
}

public struct ShowModal: StoreAction {
    public enum PresentationStyle {
        case sheet
        case fullScreenCover
    }

    public let viewFactory: ViewFactory
    public let factory: ViewModelFactory?
    public let navigation: Bool
    public let presentationStyle: PresentationStyle

    public init<V>(view: @autoclosure @escaping () -> V,
                   factory: ViewModelFactory? = nil,
                   navigation: Bool = false,
                   presentationStyle: PresentationStyle = .fullScreenCover)
                    //TODO: animated ?
                    //TODO: navigation included?
        where V: View {
            self.viewFactory = { AnyView(view()) }
            self.factory = factory
            self.navigation = navigation
            self.presentationStyle = presentationStyle
    }
}

public struct DismissModal: StoreAction {
    public enum DismissMode {
        case dismiss(Int)
        case all
    }

    public let mode: DismissMode
    public init(mode: DismissMode = .dismiss(1)) {
        self.mode = mode
    }
}

public struct Synchronize: StoreAction {
    let viewID: UUID
    public init(viewID: UUID) {
        self.viewID = viewID
    }
}
