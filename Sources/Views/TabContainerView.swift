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

    public init() { }

    public var body: some View {
        TabView(selection: $viewState.currentUUID) {
            ForEach(viewState.items, id: \.id) { item  in
                NavigationView {
                    ContainerView(id: item.id, synchronize: false)
                }
                .tag(item.id)
                .tabItem { item.tabItem }
            }
        }
    }

    private class ViewState: ObservableObject {
        @Published var currentUUID: UUID = UUID()

        @Published var items: [ItemContainer] = []

        @Published private var uuidFromState: UUID = UUID()

        @ReMVVM.Dispatcher private var dispatcher
        @ReMVVM.State private var state: Navigation?

        private var cancellables = Set<AnyCancellable>()

        init() {
            $uuidFromState
                .filter { [weak self] in $0 != self?.currentUUID }
                .assign(to: &$currentUUID)

            $currentUUID
                .filter { [weak self] in self?.uuidFromState != $0 }
                .compactMap { [weak self] in self?.items.element(for: $0)?.item as? TabNavigationItem }
                .map { $0.action }
                .sink { [weak self] action in self?.dispatcher.dispatch(action: action) }
                .store(in: &cancellables)

            $state
                .map { [weak self] state in self?.items.element(for: state.root.currentItem)?.id ?? UUID() }
                .removeDuplicates()
                .assign(to: &$uuidFromState)

            $state
                .compactMap { state -> [ItemContainer]? in
                    state.root.stacks.map { navItem, stack in
                        let id = stack.items.first?.id ?? stack.id
                        let tabItem = (navItem as? TabNavigationItem)?.tabItemFactory() ?? EmptyView().any
                        return ItemContainer(item: navItem, tabItem: tabItem, id: id)
                    }
                }
                .prefix(1) //take only first value, next value will be handled by parent view
                .assign(to: &$items)
        }
    }
}

private struct ItemContainer: Identifiable {
    let item: NavigationItem
    let tabItem: AnyView
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
