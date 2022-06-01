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

    public init() { }

    public var body: some View {
        TabView(selection: $viewState.currentUUID) {
            ForEach(viewState.items) { item  in
                NavigationView { ContainerView(id: item.id, synchronize: false) }
                    .tag(item.id)
                    .navigationViewStyle(.stack)
            }
        }
        .overlay(viewState.tabBarFactory?(viewState.items.map { $0.tabItem },
                                          $viewState.currentIndex),
                 alignment: .bottom)
        .ignoresSafeArea()
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
        @Published var currentIndex: Int = 0

        @Published var tabBarFactory: NavigationConfig.TabBarFactory? = nil

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
                .combineLatest($items) { id, items in
                    items.firstIndex { $0.id == id }
                }
                .compactMap { $0 }
                .assign(to: &$currentIndex)

            $currentIndex
                .removeDuplicates()
                .combineLatest($items) { index, items -> UUID? in
                    guard items.indices.contains(index) else { return nil }
                    return items[index].id
                }
                .compactMap { $0 }
                .assign(to: &$currentUUID)

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
                        let tabItem = (navItem as? TabNavigationItem)?.tabItemFactory() ?? EmptyView().any
                        return ItemContainer(item: navItem, tabItem: tabItem, id: id)
                    }
                }
                .prefix(1) //take only first value, next value will be handled by parent view
                .assign(to: &$items)

            $uiStateConfig
                .compactMap { $0.navigationConfigs.tabBarFactory }
                .assign(to: &$tabBarFactory)
        }
    }
}

private struct ItemContainer: Identifiable {
    let item: NavigationItem
    let tabItem: AnyView
    let id: UUID

//    static var preview: ItemContainer {
//        .init(item: PreviewNavigationTab.home, tabItem: PreviewNavigationTab.home.tabItemFactory(), id: UUID())
//    }
}

extension Array where Element == ItemContainer {
    func element(for id: UUID?) -> Element? {
        first { $0.id == id }
    }

    func element(for item: NavigationItem) -> Element? {
        first { $0.item.isEqual(to: item) }
    }
}

enum PreviewNavigationTab: String, TabNavigationItem, CaseIterableNavigationItem {
    case home = "Home"
    case tests = "Tests"
    case profile = "Profile"


    public var tabViewFactory: () -> AnyView {
        switch self {
        case .home: return { Text("HOME").any }
        case .tests: return { Text("TESTS").any }
        case .profile: return { Text("PROFILE").any }
        }
    }

    public var tabItemFactory: () -> AnyView {
        switch self {
        default: return { Image(uiImage: .add).any }
        }
    }
}
