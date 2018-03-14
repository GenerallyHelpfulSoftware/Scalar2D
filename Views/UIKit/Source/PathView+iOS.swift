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

extension UIViewContentMode
{
    var layerContentGravity: String
    {
        switch self
        {
            case .scaleAspectFill:
                return kCAGravityResizeAspectFill
            case .scaleAspectFit:
                return kCAGravityResizeAspect
            case .bottom:
                return kCAGravityBottom
            case .top:
                return kCAGravityTop
            case .left:
                return kCAGravityLeft
            case .right:
                return kCAGravityRight
            case .bottomLeft:
                return kCAGravityBottomLeft
            case .bottomRight:
                return kCAGravityBottomRight
            case .topRight:
                return kCAGravityTopRight
            case .topLeft:
                return kCAGravityTopLeft
            case .center:
                return kCAGravityCenter
            case .redraw:
                return kCAGravityCenter
            case .scaleToFill:
                return kCAGravityResizeAspectFill
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
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var fillColor: UIColor?
    {
        didSet
        {
            self.shapeLayer.fillColor = fillColor?.cgColor
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var strokeColor: UIColor?
    {
        didSet
        {
            self.shapeLayer.strokeColor = strokeColor?.cgColor
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var svgPath: String?
    {
        didSet
        {
            self.setPathString(pathString: svgPath)
            self.invalidateIntrinsicContentSize()
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    override public var contentMode: UIViewContentMode
    {
        didSet
        {
            self.layer.contentsGravity = contentMode.layerContentGravity
        }
    }
    
    public var shapeLayer: CAShapeLayer
    {
        return self.layer as! CAShapeLayer
    }
    
    override public class var layerClass: Swift.AnyClass
    {
        return CAShapeLayer.self
    }

    public override var intrinsicContentSize: CGSize {
        let pathSize = shapeLayer.path?.boundingBoxOfPath.size ?? .zero
        let sizeWithLineWidth = CGRect(origin: .zero, size: pathSize).insetBy(dx: 2 * lineWidth, dy: 2 * lineWidth).size
        return sizeWithLineWidth
    }
}
