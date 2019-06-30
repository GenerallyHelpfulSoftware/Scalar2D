//
//  PathView+Cross.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/17/16.
//  Copyright © 2016-2019 Generally Helpful Software. All rights reserved.
//
//
// The MIT License (MIT)

//  Copyright (c) 2016-2019 Generally Helpful Software

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


#if os(iOS) || os(tvOS) || os(OSX)
import Foundation
import CoreGraphics
import QuartzCore
import Scalar2D_GraphicPath
import Scalar2D_Styling


public protocol ShapeView : StyleableObject {
    
    var lineWidth: CGFloat {get set}
    var fill: CGColor? {get set}
    var stroke: CGColor? {get set}
    var svgPath: String? {get set}
    var shapeLayer: CAShapeLayer {get}

}

extension ShapeView
{
    public var fill: CGColor?
    {
        set
        {
            self.shapeLayer.fillColor = newValue
        }
        get
        {
            return self.shapeLayer.fillColor
        }
    }
    
    public var stroke: CGColor?
    {
        set
        {
            self.shapeLayer.strokeColor = newValue
        }
        get
        {
            return self.shapeLayer.strokeColor
        }
    }
    
    public func setPathString(pathString: String?)
    {
        guard let pathToRender = pathString else
        {
            self.shapeLayer.path = nil
            return
        }
        guard let cgPath = CGPath.path(fromSVGPath: pathToRender) else
        {
            print("Bad SVG: \(pathToRender)")
            return
        }
        let bounds = cgPath.boundingBox
        var transform = CGAffineTransform(translationX: -bounds.minX, y: -bounds.minY)
        let offsetPath = cgPath.copy(using: &transform) // setting path to be zero point based
        self.shapeLayer.path = offsetPath
    }
}

#endif

