//
//  PopupReducer.swift
//  
//
//  Created by Paweł Zgoda-Ferchmin on 21/09/2022.
//

import ReMVVMCore
import SwiftUI

public enum ShowPopupReducer: Reducer {
    public static func reduce(state: Navigation, with action: ShowPopup) -> Navigation  {
        state.showPopup(viewFactory: action.viewFactory)
    }
}

extension Navigation {
    var hasModals: Bool { !modals.items.isEmpty }

    func showPopup(viewFactory: @escaping ViewFactory) -> Navigation {
        if hasModals {
            return Navigation(root: root, modals: modals.showPopup(viewFactory: viewFactory))
        } else {
            return Navigation(root: root.showPopup(viewFactory: viewFactory))
        }
    }
}

extension Root {
    func showPopup(viewFactory: ViewFactory?) -> Root {
        let stacks = self.stacks.enumerated().map { index, stack -> (NavigationItem, Stack<Element>) in
            guard index == current else { return stack }
            return (stack.0, stack.1.showPopup(viewFactory: viewFactory))
        }
        return Root(current: current, stacks: stacks)
    }
}

extension Stack where StackItem == Modal {
    func showPopup(viewFactory: ViewFactory?) -> Self {
        guard let lastModal = items.last else { return self }
        switch lastModal {
        case .single(let element):
            let newElement: Modal = .single(element.withPopup(viewFactory))
            return Stack(with: items.dropLast() + [newElement])
        case .navigation(let stack):
            return Stack(with: items.dropLast() + [.navigation(stack.showPopup(viewFactory: viewFactory))])
        }
    }
}


extension Stack where StackItem == Element {
    func showPopup(viewFactory: ViewFactory?) -> Self {
        guard let newItem = items.last?.withPopup(viewFactory) else { return self }
        return Stack(with: items.dropLast() + [newItem])
    }
}

extension Element {
    func withPopup(_ factory: ViewFactory?) -> Self {
        Element(with: id,
                viewFactory: viewFactory,
                factory: viewModelFactory,
                modalPresentationStyle: modalPresentationStyle,
                popupFactory: factory)
    }
}
