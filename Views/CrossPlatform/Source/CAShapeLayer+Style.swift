//
//  CAShapeLayer+Style.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/30/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import CoreGraphics


extension CAShapeLayer : StyleAcceptor
{
    public func accept(key: PropertyKey, property: StyleProperty, context: NativeRenderingContext) -> Bool
    {
        switch (key, property)
        {
            case (.stroke_width, .unitNumber(let dimension)):
                self.lineWidth = CGFloat(context.points(value: dimension.dimension, fromUnit: dimension.unit)  ?? 0.0)
            case (.stroke, .colour(let color, let nativeColor)):
                if let cgColor = nativeColor ?? color.toCGColorWithColorContext(context)
                {
                    self.strokeColor = cgColor
                }
            case (.fill, .colour(let color, let nativeColor)):
                if let cgColor = nativeColor ?? color.toCGColorWithColorContext(context)
                {
                    self.fillColor = cgColor
                }
            default:
            return false
        }
        return true
    }
    
    
}

