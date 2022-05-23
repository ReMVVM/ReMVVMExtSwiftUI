//
//  ShowModalReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore
import SwiftUI

public enum ShowModalReducer: Reducer {
    public static func reduce(state: Navigation, with action: ShowModal) -> Navigation  {
        let modals = state.modals.append(viewFactory: action.viewFactory,
                                         factory: action.factory ?? state.viewModelFactory,
                                         navigation: action.navigation,
                                         presentationStyle: action.presentationStyle)
        return Navigation(root: state.root, modals: modals)
    }
}

extension Stack where StackItem == Modal {
    func append(viewFactory: @escaping ViewFactory, factory: ViewModelFactory, navigation: Bool, presentationStyle: ShowModal.PresentationStyle) -> Self {
        let element = Element(with: id, viewFactory: viewFactory, factory: factory, modalPresentationStyle: presentationStyle)
        let item: Modal
        if navigation {
            item = .navigation(Stack<Element>(with: [element]))
        } else {
            item = .single(element)
        }

        return Stack(with: items + [item])
    }
}
