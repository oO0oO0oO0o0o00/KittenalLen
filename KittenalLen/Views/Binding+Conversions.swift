//
//  Binding+Conversions.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
//

import SwiftUI

extension Binding {
    static func convert<
        TFrom: BinaryFloatingPoint & Sendable,
        TTo: BinaryFloatingPoint
    >(
        _ floatBinding: Binding<TFrom>
    ) -> Binding<TTo> {
        Binding<TTo> (
            get: { TTo(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFrom($0) }
        )
    }
    
    static func convert<
        TInt: BinaryInteger & Sendable,
        TFloat: BinaryFloatingPoint
    >(_ intBinding: Binding<TInt>) -> Binding<TFloat> {
        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0.rounded()) }
        )
    }

    static func convert<
        TFloat: BinaryFloatingPoint & Sendable,
        TInt: BinaryInteger
    >(
        _ floatBinding: Binding<TFloat>
    ) -> Binding<TInt> {
        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
    
    static func oneHot<T: Equatable>(
        _ binding: Binding<T>,
        current: T
    ) -> Binding<Bool> {
        Binding<Bool> (
            get: { binding.wrappedValue == current },
            set: { _ in binding.wrappedValue = current }
        )
    }
}
