//
//  ContainerView.swift
//  SwiftUITest
//
//  Created by Dariusz Grzeszczak on 09/11/2020.
//  Copyright © 2020 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI
import ReMVVMSwiftUI

public struct ContainerView: View {

    private let id: UUID
    private let synchronize: Bool
    private let linkView: LinkView

    @ReMVVM.ObservedObject private var viewState: ViewState
    @ReMVVM.Dispatcher private var dispatcher

    init(id: UUID, synchronize: Bool) {
        self.id = id
        self.synchronize = synchronize

        linkView = LinkView(id: id)
        viewState = ViewState(id: id)
    }

    public var body: some View {
        VStack {
            viewState.view
                .onDisappear {
                    if synchronize {
                        dispatcher.dispatch(action: Synchronize(viewID: id))
                    }
                }
            linkView
        }
    }

    private class ViewState: ObservableObject {
        @Published private(set) var view: AnyView = Text("No view in container").any

        @ReMVVM.State private var state: Navigation?
        private var cancellables = Set<AnyCancellable>()
        init(id: UUID) {
            $state
                .map { $0.item(with: id) }
                .filter { $0 != nil }
                .compactMap { $0?.view }
                .assign(to: &$view)
        }
    }

    private struct LinkView: View {

        @ReMVVM.ObservedObject private var viewState: ViewState

        init(id: UUID) {
            viewState = ViewState(id: id)
        }

        var body: some View {
            guard let view = viewState.view else { return EmptyView().any }
            return NavigationLink(destination: view, tag: view.id, selection: $viewState.active) {
                EmptyView()
            }.isDetailLink(false).any
        }

        private class ViewState: ObservableObject {
            @Published var active: UUID?
            @Published var view: ContainerView?

            @ReMVVM.State private var state: Navigation?

            private let id: UUID
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
        }
    }
}
