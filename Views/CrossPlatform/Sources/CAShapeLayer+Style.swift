//
//  CAShapeLayer+Style.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/30/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2019 Generally Helpful Software

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//
import CoreGraphics

extension CAShapeLayer
{
    var cgJoin : CGLineJoin
    {
        set
        {
            switch newValue
            {
                case .bevel:
                    self.lineJoin = CAShapeLayerLineJoin.bevel
                case .miter:
                    self.lineJoin = CAShapeLayerLineJoin.miter
                case .round:
                    self.lineJoin = CAShapeLayerLineJoin.round
                default:
                    break
            }
        }
        
        get
        {
            switch self.lineJoin
            {
                case CAShapeLayerLineJoin.miter:
                    return .miter
                case CAShapeLayerLineJoin.round:
                    return .round
                case CAShapeLayerLineJoin.bevel:
                    return .bevel
                default:
                    return .miter
            }
        }
    }
    
    var cgLineCap : CGLineCap
    {
        set
        {
            switch newValue
            {
                case .butt:
                    self.lineCap = CAShapeLayerLineCap.butt
                    case .round:
                    self.lineCap = CAShapeLayerLineCap.round
                case .square:
                    self.lineCap = CAShapeLayerLineCap.square
                default:
                    break
            }
        }
        get
        {
            switch self.lineCap
            {
                case CAShapeLayerLineCap.round:
                    return .round
                case CAShapeLayerLineCap.butt:
                    return .butt
                case CAShapeLayerLineCap.square:
                    return .square
                default:
                    return .butt
            }
        }
    }
}

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
            case (.stroke_line_join, .lineJoin(let join)):
                if let cgJoin = join.cgLineJoin
                {
                    self.cgJoin = cgJoin
                }
                case(.stroke_line_cap, .lineCap(let cap)):
                if let cgCap = cap.cgLineCap
                {
                    self.cgLineCap = cgCap
                }
            case (.stroke_miter_limit, .number(let limit)):
                self.miterLimit = CGFloat(limit)
            
//            case (.stroke_dash_offset, .unitNumber(let dimension)):
//            switch dimension.unit
//            {
//                case .percent:
//                    self.off
//                default:
//                break
//            }
            
            default:
            return false
        }
        return true
    }
    
    
}

