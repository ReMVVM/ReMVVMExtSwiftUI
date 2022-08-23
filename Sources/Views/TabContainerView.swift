//
//  TabContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVMSwiftUI

public struct TabContainerView: View {
    @ReMVVM.ObservedObject private var viewState = ViewState()

    @Namespace private var tabBarNamespace

    private var currentIndex: Binding<Int?> {
        $viewState.currentUUID
            .map(get: { id in viewState.items.firstIndex { $0.id == id } },
                 set: { viewState.items.with($0)?.id })
    }

    public init() { }

    public var body: some View {
        TabView(selection: $viewState.currentUUID) {
            ForEach(viewState.items) { item in
                NavigationView { ContainerView(id: item.id, synchronize: false) }
                    .tag(item.id)
                    .tabItem {
                        viewState.tabBarFactory == nil ? item.tabItem?(viewState.items.firstIndex { $0.id == item.id } == currentIndex.wrappedValue) : nil
                    }
                    .navigationViewStyle(.stack)
            }
        }
        .overlay(viewState.tabBarFactory?(viewState.items.compactMap { $0.item as? TabNavigationItem },
                                          currentIndex),
                 alignment: .bottom)
    }

    private class ViewState: ObservableObject {
        @Published var items: [ItemContainer] = []
        @Published var currentUUID: UUID = UUID() {
            didSet {
                if oldValue == currentUUID {
                    self.dispatcher.dispatch(action: Pop(mode: .popToRoot))
                }
            }
        }

        @Published var tabBarFactory: NavigationConfig.TabBarFactory?

        private var uuidFromState: UUID = UUID() {
            didSet {
                if uuidFromState != currentUUID {
                    currentUUID = uuidFromState
                }
            }
        }

        @ReMVVM.Dispatcher private var dispatcher
        @ReMVVM.State private var state: Navigation?
        @ReMVVM.State private var uiStateConfig: UIStateConfig?

        private var cancellables = Set<AnyCancellable>()

        init() {
            $currentUUID
                .removeDuplicates()
                .filter { self.uuidFromState != $0 }
                .compactMap { self.items.element(for: $0)?.item as? TabNavigationItem }
                .map { $0.action }
                .sink { action in self.dispatcher.dispatch(action: action) }
                .store(in: &cancellables)

            $state
                .combineLatest($items) { state, items in
                    items.element(for: state.root.currentItem)
                }
                .filter { ($0?.item as? TabNavigationItem) != nil }
                .compactMap { $0?.id }
                .removeDuplicates()
                .assignNoRetain(to: \.uuidFromState, on: self)
                .store(in: &cancellables)

            $state
                .compactMap { state -> [ItemContainer]? in
                    state.root.stacks.map { navItem, stack in
                        let id = stack.items.first?.id ?? stack.id
                        let tabItemFactory = (navItem as? TabNavigationItem)?.tabItemFactory
                        return ItemContainer(item: navItem, tabItem: tabItemFactory, id: id)
                    }
                }
                .prefix(1) //take only first value, next value will be handled by parent view
                .assign(to: &$items)

            $uiStateConfig
                .compactMap { $0.navigationConfig?.tabBarFactory }
                .assign(to: &$tabBarFactory)
        }
    }
}

private struct ItemContainer: Identifiable {
    let item: NavigationItem
    let tabItem: ((Bool) -> AnyView)?
    let id: UUID
}

extension Array where Element == ItemContainer {
    func element(for id: UUID?) -> Element? {
        first { $0.id == id }
    }

    func element(for item: NavigationItem) -> Element? {
        first { $0.item.isEqual(to: item) }
    }
}
