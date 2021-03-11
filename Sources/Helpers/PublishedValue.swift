//
//  PublishedValue.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI

@propertyWrapper
public struct PublishedValue<Value>: DynamicProperty {

    fileprivate class Obervable: ObservableObject {
        @Published var value: Value

        init(value: Value) {
            self.value = value
        }
    }

    @ObservedObject private var _wrappedValue: Obervable

    public var wrappedValue: Value {
        get { _wrappedValue.value }
        nonmutating set { _wrappedValue.value = newValue }
    }

    public var projectedValue: Publisher

    public struct Publisher: Combine.Publisher {

        public typealias Output = Value
        public typealias Failure = Never

        var cancellables = Set<AnyCancellable>()

        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            publisher.receive(subscriber: subscriber)
        }

        fileprivate let object: ObservedObject<Obervable>

        public var binding: Binding<Value> {
            object.projectedValue.value
        }

        private var publisher: Published<Value>.Publisher {
            object.wrappedValue.$value
        }
    }

    public init(wrappedValue: Value) {
        _wrappedValue = .init(value: wrappedValue)
        projectedValue = Publisher(object: __wrappedValue)
    }
}

extension Publisher where Self.Failure == Never {

    public func assign<Value>(to publisher: inout PublishedValue<Value>.Publisher) where Value == Output {
        let observed = publisher.object.wrappedValue
        sink { value in  observed.value = value }.store(in: &publisher.cancellables)
    }
}
