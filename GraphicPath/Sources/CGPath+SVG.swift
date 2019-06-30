  //
//  CGPath+SVG.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/7/16.
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

import Foundation
import CoreGraphics
fileprivate struct Vector2D
{
    let deltaX: CGFloat
    let deltaY: CGFloat
    
    init(deltaX: CGFloat, deltaY: CGFloat)
    {
        self.deltaX = deltaX
        self.deltaY = deltaY
    }

    private var vectorMagnitude: CGFloat
    {
        let	result = sqrt(self.deltaX*self.deltaX+self.deltaY*self.deltaY)
        return result
    }
    
    func vectorRatio(vector2: Vector2D) -> CGFloat
    {
        var result = self.deltaX*vector2.deltaX + self.deltaY*vector2.deltaY
        result /= self.vectorMagnitude*vector2.vectorMagnitude
        return result
    }
    
    func vectorAngle(vector2: Vector2D) -> CGFloat
    {
        let vectorRatio = self.vectorRatio(vector2: vector2)
        var  result = acos(vectorRatio)
        if(self.deltaX*vector2.deltaY) < (self.deltaY*vector2.deltaX)
        {
            result *= -1.0
        }
        return result
    }
}

extension CGMutablePath
{
    private struct CGPathBuilder
    {
        let tokens: [PathToken]
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        var lastCubicX₂: CGFloat?
        var lastCubicY₂: CGFloat?
        
        var lastQuadX₁: CGFloat?
        var lastQuadY₁: CGFloat?
        
        let mutablePath : CGMutablePath
        
        init(path: CGMutablePath, tokens: [PathToken])
        {
            self.mutablePath = path
            self.tokens = tokens
            
            if !path.isEmpty
            {
                let startCoordinate = path.currentPoint
                self.x = startCoordinate.x
                self.y = startCoordinate.y
            }
        }
        
        
        /**
            The smooth/shortcut operators T & S work with the control points of the immediately previous curve operators. This method just cleans the control points out if the previous operand was not a curve operatior.
        **/
        mutating func clearControlPoints()
        {
            lastCubicX₂ = nil
            lastQuadX₁ = nil
        }
        
        /**
            A routine to take the parameters provided by an SVG arc operator and add it to a CGMutablePath
            - parameters:
                - xRadius: the radius of the arc along the X axis
                - yRadius: the radious of the arc along the Y axis
                - tiltAngle: the rotation (in degrees) of the arc off the X Axis
                - largeArcFlag: whether the long path will be selected
                - sweepFlag: whether the path will travel clockwise or counterclockwise
                - endX: the absolute X coordinate of the end point. 
                - endY: the absolute Y coordinate of the end point.
         
            - warning; An end point that equals the start point will result in nothing being drawn.
         **/
        mutating private func addArc(xRadius radX: CGFloat, yRadius radY: CGFloat, tiltAngle: Double, largeArcFlag: PathToken.ArcChoice, sweepFlag: PathToken.ArcSweep, endX: CGFloat, endY: CGFloat)
        {
            //implementation notes http://www.w3.org/TR/SVG/implnote.html#ArcConversionEndpointToCenter
            // general algorithm from MIT licensed http://code.google.com/p/svg-edit/source/browse/trunk/editor/canvg/canvg.js
            // Gabe Lerner (gabelerner@gmail.com)
            // first do first aid to the parameters to keep them in line
            
            let kDegreesToRadiansConstant: Double = Double.pi/180.0
            
            defer
            {
                self.x = endX
                self.y = endY
            }
            
            if(self.x == endX && endY == self.y)
            { // do nothing
            }
            else if(radX == 0.0 || radY == 0.0) // not an actual arc, draw a line segment
            {
                self.mutablePath.addLine(to: CGPoint(x: endX, y: endY))
            }
            else // actually try to draw an arc
            {
                var xRadius = abs(radX) // make sure radius are positive
                var yRadius = abs(radY)
                let xAxisRotationDegrees = fmod(tiltAngle, 360.0)
                
                let xAxisRotationRadians = xAxisRotationDegrees*kDegreesToRadiansConstant
                
                
                let cosineAxisRotation = CGFloat(cos(xAxisRotationRadians))
                let sineAxisRotation = CGFloat(sin(xAxisRotationRadians))
                
                let deltaX = self.x-endX
                let deltaY = self.y-endY
                
                let ½DeltaX = deltaX / 2.0
                let ½DeltaY = deltaY / 2.0
                
                var xRadius² = xRadius*xRadius
                var yRadius² = yRadius*yRadius
                
                
                // steps are from the implementation notes
                // F.6.5  Step 1: Compute (x1′, y1′)
                let	translatedCurPoint = CGPoint(x: cosineAxisRotation*½DeltaX+sineAxisRotation*½DeltaY,
                   	                             y: -1.0*sineAxisRotation*½DeltaX+cosineAxisRotation*½DeltaY)
                    
                
                let translatedCurPointX² = translatedCurPoint.x*translatedCurPoint.x
                let translatedCurPointY² = translatedCurPoint.y*translatedCurPoint.y
                
                // (skipping to different section) F.6.6 Step 3: Ensure radii are large enough
                var	shouldBeNoMoreThanOne = translatedCurPointX²/(xRadius²)
                    + translatedCurPointY²/(yRadius²)
                
                if(shouldBeNoMoreThanOne > 1.0)
                {
                    xRadius *= sqrt(shouldBeNoMoreThanOne)
                    yRadius *= sqrt(shouldBeNoMoreThanOne)
                    
                    xRadius² = xRadius*xRadius
                    yRadius² = yRadius*yRadius
                    
                    shouldBeNoMoreThanOne = translatedCurPointX²/(xRadius²)
                        + translatedCurPointY²/(yRadius²)
                    if(shouldBeNoMoreThanOne > 1.0) // sometimes just a bit north of 1.0000000 after first pass
                    {
                        shouldBeNoMoreThanOne += 0.000001 // making sure
                        xRadius *= sqrt(shouldBeNoMoreThanOne)
                        yRadius *= sqrt(shouldBeNoMoreThanOne)
                        
                        xRadius² = xRadius*xRadius
                        yRadius² = yRadius*yRadius
                    }
                }
                
                var	transform = CGAffineTransform.identity
                // back to  F.6.5   Step 2: Compute (cx′, cy′)
                let  centerScalingDivisor = xRadius²*translatedCurPointY²
                    + yRadius²*translatedCurPointX²
               
                var	centerScaling = CGFloat(0.0)
                
                if(centerScalingDivisor != 0.0)
                {
                    let centerScaling² = (xRadius²*yRadius²
                        - xRadius²*translatedCurPointY²
                        - yRadius²*translatedCurPointX²)
                        / centerScalingDivisor
                    
                    centerScaling = sqrt(centerScaling²)
                    
                    
                    if(centerScaling.isNaN)
                    {
                        centerScaling = 0.0
                    }
                
                    if(sweepFlag.rawValue == largeArcFlag.rawValue)
                    {
                        
                        centerScaling *= -1.0
                    }
                }
                
                let translatedCenterPoint = CGPoint(x: centerScaling*xRadius*translatedCurPoint.y/yRadius,
                                                    y: -1.0*centerScaling*yRadius*translatedCurPoint.x/xRadius)
                
                // F.6.5  Step 3: Compute (cx, cy) from (cx′, cy′)
                
                
                let averageX = (self.x+endX)/2.0
                let averageY = (self.y+endY)/2.0
                let centerPoint = CGPoint(x:averageX+cosineAxisRotation*translatedCenterPoint.x-sineAxisRotation*translatedCenterPoint.y,
                              y: averageY+sineAxisRotation*translatedCenterPoint.x+cosineAxisRotation*translatedCenterPoint.y)
                // F.6.5   Step 4: Compute θ1 and Δθ
                
                // misusing CGPoint as a vector
                let vectorX = Vector2D(deltaX: 1.0, deltaY: 0.0)
                let vectorU = Vector2D(deltaX: (translatedCurPoint.x-translatedCenterPoint.x)/xRadius,
                                      deltaY: (translatedCurPoint.y-translatedCenterPoint.y)/yRadius)
                let vectorV = Vector2D(deltaX: (-1.0*translatedCurPoint.x-translatedCenterPoint.x)/xRadius,
                                      deltaY: (-1.0*translatedCurPoint.y-translatedCenterPoint.y)/yRadius)
                
                let	startAngle = vectorX.vectorAngle(vector2: vectorU)
                
                var	angleDelta = vectorU.vectorAngle(vector2: vectorV)
                
                let vectorRatio = vectorU.vectorRatio(vector2: vectorV)
                
                if(vectorRatio <= -1)
                {
                    angleDelta = CGFloat.pi
                }
                else if(vectorRatio >= 1.0)
                {
                    angleDelta = 0.0
                }
                
                switch sweepFlag
                {
                    case .clockwise where angleDelta > 0.0:
                        angleDelta = angleDelta - 2.0 * CGFloat.pi
                    case .counterclockwise where angleDelta < 0.0:
                        angleDelta = angleDelta - 2.0 * CGFloat.pi
                    default:
                    break
                }
                
                transform = transform.translatedBy(x: centerPoint.x, y: centerPoint.y)
                
                transform = transform.rotated(by: CGFloat(xAxisRotationRadians))
                
                let radius = (xRadius > yRadius) ? xRadius : yRadius
                let scaleX = (xRadius > yRadius) ? 1.0 : xRadius / yRadius
                let scaleY = (xRadius > yRadius) ? yRadius / xRadius : 1.0
                
                transform = transform.scaledBy(x: scaleX, y: scaleY)
                
                self.mutablePath.addArc(center: CGPoint.zero, radius: radius, startAngle: startAngle, endAngle: startAngle+angleDelta, clockwise: 0 == sweepFlag.rawValue, transform: transform)
            }
            clearControlPoints()
        }
        /**
            Loop over the tokens and add the equivalent CGPath operation to the mutablePath.
        */
        mutating func build()
        {
            for aToken in tokens
            {
                switch aToken
                {
                    case .close:
                        mutablePath.closeSubpath()
                        if !mutablePath.isEmpty // move the start point to the 
                        {
                            let startPoint = mutablePath.currentPoint
                            x = startPoint.x
                            y = startPoint.y
                        }
                    case let .moveTo(deltaX, deltaY):
                        x = x + deltaX
                        y = y + deltaY
                        
                        mutablePath.move(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case let .moveToAbsolute(newX, newY):
                        x = newX
                        y = newY
                        mutablePath.move(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case let .lineTo(deltaX, deltaY):
                        x = x + deltaX
                        y = y + deltaY
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case let .lineToAbsolute(newX, newY):
                        x = newX
                        y = newY
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                        
                    case .horizontalLineTo(let deltaX):
                        x = x + deltaX
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case .horizontalLineToAbsolute(let newX):
                        x = newX
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                        
                    case .verticalLineTo(let deltaY):
                        y = y + deltaY
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case .verticalLineToAbsolute(let newY):
                        y = newY
                        mutablePath.addLine(to: CGPoint(x: x, y: y))
                        clearControlPoints()
                    
                    case let .quadraticBezierTo(deltaX₁, deltaY₁, deltaX, deltaY):
                        let x₁ = deltaX₁ + x
                        let y₁ = deltaY₁ + y
                        x = x + deltaX
                        y = y + deltaY
                        
                        mutablePath.addQuadCurve(to: CGPoint(x: x, y: y) , control: CGPoint(x: x₁, y: y₁))
                        lastCubicX₂ = nil // clean out the last cubic as this is a quad
                        
                        lastQuadX₁ = x₁
                        lastQuadY₁ = y₁
                    
                    case let .quadraticBezierToAbsolute(x₁, y₁, newX, newY):
                        x = newX
                        y = newY
                        mutablePath.addQuadCurve(to: CGPoint(x: x, y: y) , control: CGPoint(x: x₁, y: y₁))
                        lastCubicX₂ = nil // clean out the last cubic as this is a quad
                        lastQuadX₁ = x₁
                        lastQuadY₁ = y₁
                    
                    case let .smoothQuadraticBezierTo(deltaX, deltaY):
                        var x₁ = x
                        var y₁ = y
                        
                        if let previousQuadX₁  = self.lastQuadX₁,
                            let previousQuadY₁ = self.lastQuadY₁
                        {
                            x₁ -= (previousQuadX₁-x₁)
                            y₁ -= (previousQuadY₁-y₁)
                        }
                        
                        x = x + deltaX
                        y = y + deltaY
                        
                        mutablePath.addQuadCurve(to: CGPoint(x: x, y: y) , control: CGPoint(x: x₁, y: y₁))
                        lastCubicX₂ = nil // clean out the last cubic as this is a quad
                        lastQuadX₁ = x₁
                        lastQuadY₁ = y₁
                    
                    case let .smoothQuadraticBezierToAbsolute(newX, newY):
                        var x₁ = x
                        var y₁ = y
                        
                        if let previousQuadX₁ = self.lastQuadX₁,
                            let previousQuadY₁ = self.lastQuadY₁
                        {
                            x₁ -= (previousQuadX₁-x₁)
                            y₁ -= (previousQuadY₁-y₁)
                        }
                        
                        x = newX
                        y = newY
                        
                        mutablePath.addQuadCurve(to: CGPoint(x: x, y: y) , control: CGPoint(x: x₁, y: y₁))
                        lastCubicX₂ = nil // clean out the last cubic as this is a quad
                        lastQuadX₁ = x₁
                        lastQuadY₁ = y₁
                    
                    case let .cubicBezierTo(deltaX₁, deltaY₁, deltaX₂, deltaY₂, deltaX, deltaY):
                    
                        let x₁ = x + deltaX₁
                        let y₁ = y + deltaY₁
                        let x₂ = x + deltaX₂
                        let y₂ = y + deltaY₂
                    
                        x = x + deltaX
                        y = y + deltaY
                        
                        mutablePath.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x₁, y: y₁), control2: CGPoint(x: x₂, y: y₂))
                        lastCubicX₂ = x₂
                        lastCubicY₂ = y₂
                        lastQuadX₁ = nil // clean out the last quad as this is a cubic
                    
                    case let .cubicBezierToAbsolute(x₁, y₁, x₂, y₂, newX, newY):
                    
                        x = newX
                        y = newY
                        lastCubicX₂ = x₂
                        lastCubicY₂ = y₂
                        
                        mutablePath.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x₁, y: y₁), control2: CGPoint(x: x₂, y: y₂))
                        
                        lastQuadX₁ = nil // clean out the last quad as this is a cubic
                    
                    case let .smoothCubicBezierTo(deltaX₂, deltaY₂, deltaX, deltaY):
                    
                        var x₁ = x
                        var y₁ = y
                    
                        
                        if let previousCubicX₂ = self.lastCubicX₂,
                            let previousCubicY₂ = self.lastCubicY₂
                        {
                            x₁ -= (previousCubicX₂-x₁)
                            y₁ -= (previousCubicY₂-y₁)
                        }
                        
                        lastCubicX₂ = x + deltaX₂
                        lastCubicY₂ = y + deltaY₂

                        x = x + deltaX
                        y = y + deltaY
                        
                        mutablePath.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x₁, y: y₁), control2: CGPoint(x: lastCubicX₂!, y: lastCubicY₂!))
                        
                        lastQuadX₁ = nil // clean out the last quad as this is a cubic
                    
                    case let .smoothCubicBezierToAbsolute(x₂, y₂, newX, newY):
                        
                        var x₁ = x
                        var y₁ = y
                        if let previousCubicX₂ = self.lastCubicX₂,
                            let previousCubicY₂ = self.lastCubicY₂
                        {
                            x₁ -= (previousCubicX₂-x₁)
                            y₁ -= (previousCubicY₂-y₁)
                        }
                        
                        x = newX
                        y = newY
                        lastCubicX₂ = CGFloat(x₂)
                        lastCubicY₂ = CGFloat(y₂)
                        
                        mutablePath.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: x₁, y: y₁), control2: CGPoint(x: lastCubicX₂!, y: lastCubicY₂!))
                        
                        lastQuadX₁ = nil // clean out the last quad as this is a cubic
                    
                    case let .arcTo(xRadius, yRadius, tiltAngle, largeArcFlag, sweepFlag, deltaX, deltaY):
                       
                        self.addArc(xRadius: xRadius, yRadius: yRadius, tiltAngle: tiltAngle, largeArcFlag: largeArcFlag, sweepFlag: sweepFlag, endX: x + deltaX, endY: y + deltaY)

                    case let .arcToAbsolute(xRadius, yRadius, tiltAngle, largeArcFlag, sweepFlag, newX, newY):
                        
                        self.addArc(xRadius: xRadius, yRadius: yRadius, tiltAngle: tiltAngle, largeArcFlag: largeArcFlag, sweepFlag: sweepFlag, endX: newX, endY: newY)
                    
                    case .bad(_, _):
                    break
                }
            }
        }
        
    }
    /**
        There might be a case where you would want to add an SVG path to a pre-existing CGMutablePath.
        - parameters: 
            - svgPath: a (hopefully) well formatted SVG path.
        - returns: true if the SVG path was valid, false otherwise. 
     **/
    public func add(svgPath: String) -> Bool
    {
        do
        {
            let tokens = try svgPath.asPathTokens()
            var builder = CGPathBuilder(path: self, tokens: tokens)
            
            builder.build()
            return true
        }
        catch
        {
            return false
        }
    }

    // following convenience init is not allowed by the current compiler
//    public convenience init?(svgPath: String)
//    {
//        self.init()
//        if !self.addSVGPath(svgPath: svgPath)
//        {
//            return nil 
//        }
//    }
}

extension CGPath
{
    /**
     A factory method to create an immutable CGPath from an SVG path string.
     
        - parameters:
            - svgPath: A (hopefully) valid path complying to the SVG path specification. 
        - returns: an optional CGPath which will be .Some if the SVG path string was valid.
     **/
    public static func path(fromSVGPath svgPath: String) -> CGPath?
    {
        let mutableResult = CGMutablePath()
        if mutableResult.add(svgPath: svgPath)
        {
            return mutableResult.copy()
        }
        else
        {
            return nil 
        }
    }
    
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
            default:
                break 
            }
            
        }
        return result as String
    }
}

