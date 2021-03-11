//
//  DismissModalReducer.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import ReMVVM

public enum DismissModalReducer: Reducer {
    public static func reduce(state: Navigation, with action: NavigationActions.DismissModal) -> Navigation  {
        Navigation(root: state.root, modals: state.modals.dropLast())
    }
}

extension Stack where StackItem == Modal {

    func dropLast() -> Self {
        guard items.count > 0 else { return self }
        return Stack(with: items.dropLast())
    }
}
