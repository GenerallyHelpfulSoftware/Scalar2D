//
//  NSBezierPath+SVG.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/7/16.
//
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


#if os(OSX)
import Foundation
import Cocoa

    
public extension NSBezierPath
{
    public convenience init?(svgPath: String)
    {
        let cgPath = CGMutablePath()
        if cgPath.add(svgPath: svgPath) == false
        {
            return nil // wasn't a valid SVG path
        }
        
        self.init()
        
        let myself = self
        
        cgPath.iterate { (element) in
            let points = element.points // remember that points are unsafe (thus use of pointee below)
        
            switch element.type
            {
                case .moveToPoint:
                    let newPoint = points.pointee
                    myself.move(to: NSPoint(x: newPoint.x, y: newPoint.y))
                case .addLineToPoint:
                    let newPoint = points.pointee
                    myself.line(to: NSPoint(x: newPoint.x, y: newPoint.y))
                case .closeSubpath:
                    myself.close()
                case .addCurveToPoint: // add a cubic bezier
                    let controlPoint1 = points.pointee
                    let controlPoint2 = points.advanced(by: 1).pointee
                    let nextPoint = points.advanced(by: 2).pointee
                    myself.curve(to: nextPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                case .addQuadCurveToPoint: // As NSBezierPath has no native quad curve element, convert to cubic.
                    let ⅔ = CGFloat(2.0/3.0)
                    
                    let quadControlPoint = points.pointee
                    let nextPoint = points.advanced(by: 1).pointee
                    
                    let startPoint = myself.currentPoint 
                    
                    let control1X = startPoint.x + ⅔*(quadControlPoint.x-startPoint.x)
                    let control1Y = startPoint.y + ⅔*(quadControlPoint.y-startPoint.y)
                    
                    let controlPoint1 = NSPoint(x: control1X, y: control1Y)
                    
                    let control2X = nextPoint.x + ⅔*(quadControlPoint.x-nextPoint.x)
                    let control2Y = nextPoint.y + ⅔*(quadControlPoint.y-nextPoint.y)
                    
                    let controlPoint2 = NSPoint(x: control2X, y: control2Y)
                    
                    myself.curve(to: nextPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
    }
}

#endif
