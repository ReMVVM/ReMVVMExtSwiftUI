//
//  ContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 09/11/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVM

public struct ContainerView: View {

    private let id: UUID
    private let synchronize: Bool
    private let linkView: LinkView

    @PublishedValue private var item: Element?
    @StateSourced(from: .store) private var state: Navigation!
    @Provided private var dispatcher: Dispatcher

    init(id: UUID, synchronize: Bool) {
        self.id = id
        self.synchronize = synchronize

        linkView = LinkView(id: id)

        $state
            .map { $0.item(with: id)}
            .filter { $0 != nil }
            .assign(to: &$item)
    }

    public var body: some View {
        guard let item = item else { return Text("No view in container").any }
        return VStack {
            item.view
                .onDisappear {
                    if synchronize {
                        dispatcher.dispatch(action: Synchronize(viewID: id))
                    }
                }
            linkView
        }.any
    }

    private struct LinkView: View {

        private let id: UUID

        @PublishedValue private var active: UUID?
        @PublishedValue private var view: ContainerView?

        @StateSourced(from: .store) private var state: Navigation!

        init(id: UUID) {
            self.id = id

            $state
                .map { $0.nextItem(for: id)?.id }
                .removeDuplicates()
                .assign(to: &$active)

            $state
                .compactMap { $0.nextId(for: id) }
                .removeDuplicates()
                .map { ContainerView(id: $0, synchronize: true) }
                .assign(to: &$view)
        }

        var body: some View {
            guard let view = view else { return Text("EmptyLink").any }
            return NavigationLink(destination: view, tag: view.id, selection: $active.binding) {
                EmptyView()
            }.isDetailLink(false).any
        }
    }
}
