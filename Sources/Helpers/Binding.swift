//
//  File.swift
//  
//
//  Created by Paweł Zgoda-Ferchmin on 01/06/2022.
//

import Combine
import SwiftUI

extension Binding {
    func map<T>(get: @escaping (Value) -> T?, set: @escaping (T?) -> Value?) -> Binding<T?> {
        Binding<T?>(get: { get(wrappedValue) },
                    set: { wrappedValue = set($0) ?? wrappedValue })
    }
}

extension Array {
    func with(_ index: Array.Index?) -> Array.Element? {
        guard let index = index, indices.contains(index) else { return nil }
        return self[index]
    }
}
