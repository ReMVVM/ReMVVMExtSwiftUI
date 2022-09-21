//
//  File.swift
//  
//
//  Created by Paweł Zgoda-Ferchmin on 21/09/2022.
//

import Combine
import SwiftUI
import ReMVVMSwiftUI

public struct PopupContainerView: View {
    @ReMVVM.ObservedObject private var viewState: ViewState
    @ReMVVM.Dispatcher private var dispatcher

    private let synchronizeId: UUID?

    init(id: UUID) {
        self.init(viewType: .id(id))
    }

    init<V: View>(view: V, id: UUID) {
        self.init(viewType: .view(view.any, id))
    }

    private init(viewType: ViewType) {
        viewState = ViewState(viewType: viewType)
        if case .id(let id) = viewType {
            synchronizeId = id
        } else {
            synchronizeId = nil
        }
    }

    public var body: some View {
        viewState.view
            .popup(isPresented: viewState.isPopupActive, content: viewState.popupView)
            .onDisappear {
                guard let id = synchronizeId else { return }
                dispatcher.dispatch(action: Synchronize(viewID: id))
            }
    }

    private enum ViewType {
        case view(AnyView, UUID)
        case id(UUID)
    }

    private class ViewState: ObservableObject {
        //@Published var isChildModalActive: Bool = false
        //@Published var sheet: UUID?
        //@Published var fullScreenCover: UUID?
        // @Published var isPopupActive: Bool = false

        var isPopupActive: Bool { popupView != nil }

        @Published private(set) var view: AnyView?
        @Published private(set) var popupView: AnyView?

        @ReMVVM.State private var state: Navigation?

        init(viewType: ViewType) {
            //let sheetPublisher: AnyPublisher<UUID?, Never>
            //let fullScreenPublisher: AnyPublisher<UUID?, Never>

            switch viewType {
            case .id(let id):
                $state.map { $0.item(with: id)?.view }.assign(to: &$view)
                $state.map { $0.item(with: id)?.popup }.assign(to: &$popupView)
            case .view(let view, let id):
                self.view = view
                $state.map { $0.item(with: id)?.popup }.assign(to: &$popupView)
            }
        }
    }
}


public struct PopupModifier<PopupContent>: ViewModifier where PopupContent: View {
    var isPresented: Bool

    var content: () -> PopupContent
    var animation: Animation

    public func body(content: Content) -> some View {
        content
            .overlay(sheet())
    }

    func sheet() -> some View {
        content()
            .opacity(isPresented ? 1 : 0)
            .animation(animation, value: isPresented)
    }

    public init(isPresented: Bool,
                animation: Animation,
                content: @escaping () -> PopupContent) {
        self.isPresented = isPresented
        self.animation = animation
        self.content = content
    }
}

public extension View {
    func popup<Content: View>(isPresented: Bool,
                              animation: Animation = .easeOut(duration: 0.3),
                              content: @escaping @autoclosure () -> Content) -> some View {
        self
            .modifier(PopupModifier(isPresented: isPresented,
                                    animation: animation,
                                    content: content))
    }
}
