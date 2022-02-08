//
//  DynamicBox.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation

final class DynamicBox<T> {
 
    typealias Listener = (T) -> Void
    var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
