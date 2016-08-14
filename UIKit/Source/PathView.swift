//
//  PathView.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/10/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import UIKit

@IBDesignable public class PathView: UIView {

    @IBInspectable public var lineWidth: CGFloat = 1
    {
        didSet
        {
            self.shapeLayer.lineWidth = lineWidth
        }
    }
    
    @IBInspectable public var fillColor: UIColor?
    {
        didSet
        {
            self.shapeLayer.fillColor = fillColor?.cgColor
        }
    }
    
    @IBInspectable public var strokeColor: UIColor?
    {
        didSet
        {
            self.shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }
    
    @IBInspectable public var svgPath: String?
    {
        didSet
        {
            guard let pathToRender = svgPath else
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
    
    private var shapeLayer: CAShapeLayer
    {
        return self.layer as! CAShapeLayer
    }
    
    override public class var layerClass: Swift.AnyClass
    {
        return CAShapeLayer.self
    }

}
