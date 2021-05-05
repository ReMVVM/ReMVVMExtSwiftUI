//
//  Publisher.swift
//  
//
//  Created by Dariusz Grzeszczak on 09/03/2021.
//  Copyright © 2021 Dariusz Grzeszczak. All rights reserved.
//

import Combine
import SwiftUI

extension Publisher where Self.Failure == Never {

    func assignNoRetain<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
            guard let object = object else { return }
            _ = Just(value).assign(to: keyPath, on: object)
        }
    }

    func assignNoRetain<Root>(optional keyPath: ReferenceWritableKeyPath<Root, Self.Output?>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
            guard let object = object else { return }
            _ = Just(value).assign(to: keyPath, on: object)
        }
    }

    func assign<Root>(optional keyPath: ReferenceWritableKeyPath<Root, Self.Output?>, on object: Root) -> AnyCancellable {
        sink { value in  _ = Just(value).assign(to: keyPath, on: object) }
    }
}
