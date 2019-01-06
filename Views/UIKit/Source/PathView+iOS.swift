//
//  PathView.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/10/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
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

import UIKit

extension UIView.ContentMode
{
    var layerContentGravity: String
    {
        switch self
        {
            case .scaleAspectFill:
                return CALayerContentsGravity.resizeAspectFill.rawValue
            case .scaleAspectFit:
                return CALayerContentsGravity.resizeAspect.rawValue
            case .bottom:
                return CALayerContentsGravity.bottom.rawValue
            case .top:
                return CALayerContentsGravity.top.rawValue
            case .left:
                return CALayerContentsGravity.left.rawValue
            case .right:
                return CALayerContentsGravity.right.rawValue
            case .bottomLeft:
                return CALayerContentsGravity.bottomLeft.rawValue
            case .bottomRight:
                return CALayerContentsGravity.bottomRight.rawValue
            case .topRight:
                return CALayerContentsGravity.topRight.rawValue
            case .topLeft:
                return CALayerContentsGravity.topLeft.rawValue
            case .center:
                return CALayerContentsGravity.center.rawValue
            case .redraw:
                return CALayerContentsGravity.center.rawValue
            case .scaleToFill:
                return CALayerContentsGravity.resizeAspectFill.rawValue
        }
    }
}

@IBDesignable public class PathView: UIView, ShapeView {

    @IBInspectable public var lineWidth: CGFloat = 1
    {
        didSet
        {
            self.shapeLayer.lineWidth = lineWidth
            self.invalidateIntrinsicContentSize()
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
            self.setPathString(pathString: svgPath)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    @IBInspectable public var strokeStart : CGFloat = 0.0
    {
        didSet
        {
            self.shapeLayer.strokeStart = self.strokeStart
        }
    }
    
    @IBInspectable public var strokeEnd : CGFloat = 1.0
    {
        didSet
        {
            self.shapeLayer.strokeEnd = self.strokeEnd
        }
    }
    
    override public var contentMode: UIView.ContentMode
    {
        didSet
        {
            let layerMode = contentMode.layerContentGravity
            self.layer.contentsGravity = CALayerContentsGravity(rawValue: layerMode)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize
    {
        return (self.shapeLayer.path?.boundingBox ?? CGRect.zero).size
    }
    
    public var shapeLayer: CAShapeLayer
    {
        return (self.layer as! PathViewLayer).shapeLayer
    }
    
    override public class var layerClass: Swift.AnyClass
    {
        return PathViewLayer.self
    }
    
//    override public func layoutSubviews() {
//        super.layoutSubviews()
//        self.layer.frame = self.bounds
//        self.layer.needsLayout()
//    }

}
