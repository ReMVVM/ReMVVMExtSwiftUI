//
//  HidePopupReducer.swift
//  
//
//  Created by Paweł Zgoda-Ferchmin on 21/09/2022.
//

import Foundation
import ReMVVMCore

public enum HidePopupReducer: Reducer {
    public static func reduce(state: Navigation, with action: HidePopup) -> Navigation  {
        state.hidePopup()
    }
}

extension Navigation {
    func hidePopup() -> Navigation {
        if hasModals {
            return Navigation(root: root, modals: modals.showPopup(viewFactory: nil))
        } else {
            return Navigation(root: root.showPopup(viewFactory: nil))
        }
    }
}
