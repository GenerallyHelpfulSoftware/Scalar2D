//
//  NSBezierPath+SVG.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/7/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//


#if os(OSX)
import Foundation
import Cocoa
    
public extension NSBezierPath
{
    public convenience init?(svgPath: String)
    {
        let cgPath = CGMutablePath()
        guard cgPath.addSVGPath(svgPath: svgPath) == true  else
        {
            return nil
        }
        
        self.init()
        
        var myself = self
        
        cgPath.apply(info: &myself, function: { (theBezier, anElement) in
            
            let myBezier = Unmanaged<NSBezierPath>.fromOpaque(theBezier!).takeUnretainedValue()
            let points = anElement.pointee.points
            
            
            switch anElement.pointee.type
            {
                case .moveToPoint:
                    let newPoint = points.pointee
                    myBezier.move(to: NSPoint(x: newPoint.x, y: newPoint.y))
                case .addLineToPoint:
                    let newPoint = points.pointee
                    myBezier.line(to: NSPoint(x: newPoint.x, y: newPoint.y))
                case .closeSubpath:
                    myBezier.close()
                case .addCurveToPoint:
                    let controlPoint1 = points.pointee
                    let controlPoint2 = points.advanced(by: 1).pointee
                    let nextPoint = points.advanced(by: 2).pointee
                    myBezier.curve(to: nextPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                case .addQuadCurveToPoint:
                    let ⅔ = CGFloat(2.0/3.0)
                
                    let quadControlPoint = points.pointee
                    let nextPoint = points.advanced(by: 1).pointee
                
                    let startPoint = myBezier.currentPoint ?? NSPoint(x: 0, y: 0)
                
                    let control1X = startPoint.x + ⅔*(quadControlPoint.x-startPoint.x)
                    let control1Y = startPoint.y + ⅔*(quadControlPoint.y-startPoint.y)
                    
                    let controlPoint1 = NSPoint(x: control1X, y: control1Y)
                
                    let control2X = nextPoint.x + ⅔*(quadControlPoint.x-nextPoint.x)
                    let control2Y = nextPoint.y + ⅔*(quadControlPoint.y-nextPoint.y)
                    
                    let controlPoint2 = NSPoint(x: control2X, y: control2Y)
                
                    myBezier.curve(to: nextPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                
                
            }
        })
        
    
    }
}
    
    

#endif
