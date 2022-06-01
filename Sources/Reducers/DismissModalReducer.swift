//
//  DismissModalReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVMCore
import UIKit

public enum DismissModalReducer: Reducer {
    public static func reduce(state: Navigation, with action: DismissModal) -> Navigation  {
        switch action.mode {
        case .dismiss(let count):
            return Navigation(root: state.root, modals: state.modals.dropLast(count))
        case .all:
            return Navigation(root: state.root, modals: state.modals.dropAll())
        }
    }
}

extension Stack where StackItem == Modal {
    func dropLast(_ count: Int) -> Self {
        guard items.count > 0 else { return self }
        guard items.count >= count else { return Stack(with: items.dropLast(items.count)) }
        return Stack(with: items.dropLast(count))
    }

    func dropAll() -> Self {
        Stack(with: [])
    }
}
