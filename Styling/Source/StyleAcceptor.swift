//
//  StyleAcceptor.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/31/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(OSX)
public typealias NativeRenderingContext = StyleContext & ColorContext
#else
public typealias NativeRenderingContext = StyleContext
#endif

/**
 Any entity capable of accepting a key style property
 **/
public protocol StyleAcceptor
{
    func accept(key: PropertyKey, property: StyleProperty, context: NativeRenderingContext) -> Bool
}

public extension StyleAcceptor
{
    func accept(property: GraphicStyle, context: NativeRenderingContext) -> Bool
    {
        guard let style = context.resolve(property: property) else
        {
            return false
        }
        return self.accept(key: property.key, property: style, context: context)
    }
}
