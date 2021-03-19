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

    @PublishedValue private var view: AnyView?
    @PublishedValue private var modal: UUID?
    @PublishedValue private var isChildModalActive: Bool = false

    @StateSourced(from: .store) private var state: Navigation!

    @Provided private var dispatcher: Dispatcher

    init(id: UUID, isModalActive: Binding<Bool>) {
        _isModalActive = isModalActive
        modalPublisher(for: id).assign(to: &$modal)
        viewPublisher(for: id).assign(to: &$view)
    }

    init<V: View>(view: V, isModalActive: Binding<Bool>) {
        _isModalActive = isModalActive
        modalPublisher().assign(to: &$modal)
        self.view = view.any
    }

    public var body: some View {
        guard let view = view else { return Text("Empty modal").any }

        return view.sheet(item: $modal.binding, content: { id in
            ModalContainerView(id: id, isModalActive: $isChildModalActive.binding)
                .onAppear() {
                    self.isModalActive = true
                }
                .onDisappear(){
                    self.isModalActive = false
                }
        }).any
    }

    private func modalPublisher(for id: UUID? = nil) -> AnyPublisher<UUID?, Never> {
        $state
            .map { state -> UUID? in
                if let id = id {
                    return state.modals.nextItem(for: id)?.id
                } else {
                    return state.modals.items.first?.id
                }
            }
            .combineLatest($isChildModalActive) { ($0, $1) }
            .filter { $0.0 != nil || $0.1 == false }
            .map { $0.0 }
    //                .filter { [unowned self] s in s != nil || childVisible == false }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private func viewPublisher(for id: UUID) -> AnyPublisher<AnyView?, Never> {
        $state
            .compactMap { state -> Modal? in
                guard let item = state.modals.item(with: id) else { return nil }
                return item
            }
            .removeDuplicates { $0.id == $1.id }
            .map {
                let containerView = ContainerView(id: $0.id, synchronize: false)
                let view = $0.hasNavigation ? NavigationView { containerView }.any : containerView.any
                return view
                    .onDisappear {
                        dispatcher.dispatch(action: Synchronize(viewID: id))
                    }
                    .any
            }
            .eraseToAnyPublisher()
    }
}
