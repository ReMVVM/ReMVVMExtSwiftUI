//
//  ModalContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 09/11/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVM

public struct ModalContainerView: View {

    @Binding private var isModalActive: Bool

    @SourcedObservedObject private var viewState: ViewState
    @SourcedDispatcher private var dispatcher

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

        viewState.view.sheet(item: $viewState.modal, content: { id in
            ModalContainerView(id: id, isModalActive: $viewState.isChildModalActive)
                .source(from: _dispatcher)
                .onAppear() {
                    self.isModalActive = true
                }
                .onDisappear(){
                    self.isModalActive = false
                }
        })
        .onDisappear {
            guard let id = synchronizeId else { return }
            dispatcher.dispatch(action: Synchronize(viewID: id))
        }
    }

    private enum ViewType {
        case view(_: AnyView)
        case id(_: UUID)
    }

    private class ViewState: ObservableObject {
        @Published var isChildModalActive: Bool = false
        @Published var modal: UUID?

        @Published private(set) var view: AnyView = Text("Empty modal").any

        @Sourced private var state: Navigation?
        private var cancellables = Set<AnyCancellable>()

        init(viewType: ViewType) {

            let modalPublisher: AnyPublisher<UUID?, Never>

            switch viewType {
            case .id(let id):
                modalPublisher = $state.map { $0.modals.nextItem(for: id)?.id }.eraseToAnyPublisher()
                $state
                    .compactMap { $0.modals.item(with: id) }
                    .removeDuplicates { $0.id == $1.id }
                    .map {
                        let containerView = ContainerView(id: $0.id, synchronize: false)
                        let view = $0.hasNavigation ? NavigationView { containerView }.any : containerView.any
                        return view.any
                    }
                    .assignNoRetain(to: \.view, on: self)
                    .store(in: &cancellables)

            case .view(let view):
                modalPublisher = $state.map { $0.modals.items.first?.id }.eraseToAnyPublisher()
                self.view = view
            }

            modalPublisher
                .combineLatest($isChildModalActive) { ($0, $1) }
                .filter { $0.0 != nil || $0.1 == false }
                .map { $0.0 }
        //                .filter { [unowned self] s in s != nil || childVisible == false }
                .removeDuplicates()
                .assignNoRetain(to: \.modal, on: self)
                .store(in: &cancellables)
        }
    }
}
