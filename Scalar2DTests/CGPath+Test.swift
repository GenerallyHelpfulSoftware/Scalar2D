//
//  CGPath+Test.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/13/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
// The MIT License (MIT)

//  Copyright (c) 2016 Generally Helpful Software

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

import Foundation
import CoreGraphics

public extension CGPath
{
    public func asString() -> String
    {
        let result = NSMutableString()
        
        self.iterate { (element) in
            let points = element.points
            
            switch element.type
            {
                case .moveToPoint:
                    let newPoint = points.pointee
                    
                    result.append("M (\(newPoint.x), \(newPoint.y))\n")
                case .addLineToPoint:
                    let newPoint = points.pointee
                    result.append("L (\(newPoint.x), \(newPoint.y))\n")
                case .closeSubpath:
                    result.append("Z\n")
                case .addCurveToPoint:
                    let controlPoint1 = points.pointee
                    let controlPoint2 = points.advanced(by: 1).pointee
                    let nextPoint = points.advanced(by: 2).pointee
                    
                    result.append("C (\(controlPoint1.x), \(controlPoint1.y), \(controlPoint2.x), \(controlPoint2.y), \(nextPoint.x), \(nextPoint.y))\n")
                    
                case .addQuadCurveToPoint:
                    
                    let quadControlPoint = points.pointee
                    let nextPoint = points.advanced(by: 1).pointee
                    result.append("Q (\(quadControlPoint.x), \(quadControlPoint.y), \(nextPoint.x), \(nextPoint.y))\n")
            }

        }
        return result as String
    }
}
