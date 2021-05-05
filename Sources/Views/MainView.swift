//
//  MainView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 09/11/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVM

public struct MainView: View {

    @SourcedObservedObject private var viewState = ViewState()

    public init() { }

    public var body: some View {
        VStack {
            ModalContainerView(view: viewState.view, isModalActive: $viewState.isModalActive)
        }
    }

    private class ViewState: ObservableObject {
        @Published var isModalActive = false
        @Published var view: AnyView?

        @Sourced private var state: Navigation?
        private var cancellables = Set<AnyCancellable>()

        init() {
            $state
                .removeDuplicates { left, right in
                    if  left.root.currentItem.isType(of: RootNavigationItem.self) &&
                        right.root.currentItem.isType(of: RootNavigationItem.self) {

                        return left.root.currentStack.items.first?.id == right.root.currentStack.items.first?.id
                    }

                    return left.root.currentItem.isEqualType(to: right.root.currentItem)
                }
                .combineLatest($isModalActive) { ($0, $1) }
                .filter { $0.1 == false }
                .map { type(of: $0.0.root.currentItem).viewFactory() }
                .assignNoRetain(to: \.view, on: self)
                .store(in: &cancellables)
        }
    }
}
