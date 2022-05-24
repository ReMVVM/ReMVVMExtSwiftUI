//
//  ModalContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 09/11/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVMSwiftUI

public struct ModalContainerView: View {

    @Binding private var isModalActive: Bool

    @ReMVVM.ObservedObject private var viewState: ViewState
    @ReMVVM.Dispatcher private var dispatcher

    private let synchronizeId: UUID?

    init(id: UUID, isModalActive: Binding<Bool>) {
        self.init(viewType: .id(id), isModalActive: isModalActive)
    }

    init<V: View>(view: V, isModalActive: Binding<Bool>) {
        self.init(viewType: .view(view.any), isModalActive: isModalActive)
    }

    private init(viewType: ViewType, isModalActive: Binding<Bool>) {
        viewState = ViewState(viewType: viewType)
        _isModalActive = isModalActive
        if case .id(let id) = viewType {
            synchronizeId = id
        } else {
            synchronizeId = nil
        }
    }

    public var body: some View {
        viewState.view
            .sheet(item: $viewState.sheet) { id in
                ModalContainerView(id: id, isModalActive: $viewState.isChildModalActive)
                    .source(from: _dispatcher)
                    .onAppear() { self.isModalActive = true }
                    .onDisappear() { self.isModalActive = false }
            }
            .fullScreenCover(item: $viewState.fullScreenCover) { id in
                ModalContainerView(id: id, isModalActive: $viewState.isChildModalActive)
                    .source(from: _dispatcher)
                    .onAppear() { self.isModalActive = true }
                    .onDisappear() { self.isModalActive = false }
            }
            .onDisappear {
                guard let id = synchronizeId else { return }
                dispatcher.dispatch(action: Synchronize(viewID: id))
            }
    }

    private enum ViewType {
        case view(AnyView)
        case id(UUID)
    }

    private class ViewState: ObservableObject {
        @Published var isChildModalActive: Bool = false
        @Published var sheet: UUID?
        @Published var fullScreenCover: UUID?

        @Published private(set) var view: AnyView = Text("Empty modal").any

        @ReMVVM.State private var state: Navigation?

        init(viewType: ViewType) {
            let sheetPublisher: AnyPublisher<UUID?, Never>
            let fullScreenPublisher: AnyPublisher<UUID?, Never>

            switch viewType {
            case .id(let id):
                sheetPublisher = $state
                    .map { $0.modals.nextItem(for: id) }
                    .filter { $0?.presentationStyle != .fullScreenCover }
                    .map { $0?.id }
                    .eraseToAnyPublisher()

                fullScreenPublisher = $state
                    .map { $0.modals.nextItem(for: id) }
                    .filter { $0?.presentationStyle != .sheet }
                    .map { $0?.id }
                    .eraseToAnyPublisher()

                $state
                    .compactMap { $0.modals.item(with: id) }
                    .removeDuplicates { $0.id == $1.id }
                    .map {
                        let containerView = ContainerView(id: $0.id, synchronize: false)
                        let view = $0.hasNavigation ? NavigationView { containerView }.any : containerView.any
                        return view.any
                    }
                    .assign(to: &$view)

            case .view(let view):
                sheetPublisher = $state
                    .map { $0.modals.items.first }
                    .filter { $0?.presentationStyle != .fullScreenCover }
                    .map { $0?.id }
                    .eraseToAnyPublisher()

                fullScreenPublisher = $state
                    .map { $0.modals.items.first }
                    .filter { $0?.presentationStyle != .sheet }
                    .map { $0?.id }
                    .eraseToAnyPublisher()

                self.view = view
            }

            sheetPublisher
                .combineLatest($isChildModalActive) { ($0, $1) }
                .filter { $0.0 != nil || $0.1 == false }
                .map { $0.0 }
                .removeDuplicates()
                .assign(to: &$sheet)

            fullScreenPublisher
                .combineLatest($isChildModalActive) { ($0, $1) }
                .filter { $0.0 != nil || $0.1 == false }
                .map { $0.0 }
                .removeDuplicates()
                .assign(to: &$fullScreenCover)
        }
    }
}
