//
//  TabContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 01/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVM

public struct TabContainerView: View {

    @PublishedValue private var currentUUID: UUID = UUID()

    private var items: [ItemContainer] = []
    private var cancelable: Cancellable!

    @StateSourced(from: .store) private var state: Navigation!

    @Provided private var dispatcher: Dispatcher

    public init() {

        items = state.root.stacks.map { navItem, stack in
            let uuid = stack.items.first?.id ?? stack.id
            let tabItem = (navItem as? TabNavigationItem)?.tabItemFactory() ?? EmptyView().any
            return ItemContainer(item: navItem, tabItem: tabItem, uuid: uuid)
        }

        currentUUID = items.element(for: state.root.currentItem)?.uuid ?? UUID()
        
        $state
            .compactMap { $0.root.currentItem }
            .compactMap { [currentUUID, items] newItem -> (ItemContainer, ItemContainer)? in
                guard let currentContainer = items.element(for: currentUUID),
                      let newContainer = items.element(for: newItem)
                else { return nil }
                return (currentContainer, newContainer)
            }
            .filter { $0.0.item.isEqualType(to: $0.1.item) }
            .map { $0.1.uuid }
            .removeDuplicates()
            .assign(to: &$currentUUID)

        cancelable = $currentUUID
            .removeDuplicates()
            .sink { [items, dispatcher] uuid in
                if let tabItem = items.element(for: uuid)?.item as? TabNavigationItem { // user tapped
                    dispatcher.dispatch(action: tabItem.action)
                }
            }
    }

    public var body: some View {
        TabView(selection: $currentUUID.binding) {
            ForEach(items, id: \.uuid) { item  in
                NavigationView {
                    ContainerView(id: item.uuid, synchronize: false)
                }
                .tag(item.uuid)
                .tabItem { item.tabItem }
            }
        }
    }
}

private struct ItemContainer {
    let item: NavigationItem
    let tabItem: AnyView
    let uuid: UUID
}

extension Array where Element == ItemContainer {

    func element(for uuid: UUID?) -> Element? {
        guard let uuid = uuid else { return nil }
        return first { $0.uuid == uuid }
    }

    func element(for item: NavigationItem) -> Element? {
        first { $0.item.isEqual(to: item) }
    }
}
