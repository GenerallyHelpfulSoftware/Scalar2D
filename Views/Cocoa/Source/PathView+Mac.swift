//
//  PathView+Mac.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/17/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import Cocoa
import CoreGraphics


@IBDesignable public  class PathView: NSView, ShapeView {
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        let myLayer = CAShapeLayer()
        self.layer = myLayer
    }
    
    @IBInspectable public var svgPath: String?
    {
        didSet
        {
            self.setPathString(pathString: svgPath)
        }
    }
    
    @IBInspectable public var lineWidth: CGFloat = 1
    {
        didSet
        {
            self.shapeLayer.lineWidth = lineWidth
        }
    }
    
    @IBInspectable public var fillColor: NSColor?
    {
        didSet
        {
            
            self.shapeLayer.fillColor = fillColor?.cgColor
        }
    }
    
    @IBInspectable public var strokeColor: NSColor?
    {
        didSet
        {
            self.shapeLayer.strokeColor = strokeColor?.cgColor
        }
    }

    override public var isFlipped: Bool // to be like the iOS version
    {
        return true
    }
    
    public var shapeLayer: CAShapeLayer
    {
        return self.layer as! CAShapeLayer
    }
}
