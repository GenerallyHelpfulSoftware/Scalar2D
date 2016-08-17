//
//  PathView+Cross.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/17/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreGraphics
import QuartzCore

protocol ShapeView {
    
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
        guard let cgPath = CGPath.pathFromSVGPath(svgPath: pathToRender) else
        {
            print("Bad SVG: \(pathToRender)")
            return
        }
        self.shapeLayer.path = cgPath
    }
}
