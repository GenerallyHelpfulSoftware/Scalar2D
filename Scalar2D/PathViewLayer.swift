//
//  PathViewLayer.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/5/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//

import CoreGraphics

class PathViewLayer: CALayer {
    let shapeLayer  = CAShapeLayer()
    override func layoutSublayers() {
        super.layoutSublayers()
        
        if self.shapeLayer.superlayer == nil
        {
            self.needsDisplayOnBoundsChange = true 
            self.shapeLayer.contentsScale = self.contentsScale
            self.shapeLayer.needsDisplayOnBoundsChange = true
            self.shapeLayer.backgroundColor = Colour.clear.toCGColorWithColorContext()
            self.addSublayer(self.shapeLayer)
        }
        
        guard let path = self.shapeLayer.path, !bounds.isEmpty else
        {
            self.shapeLayer.frame = self.bounds
            return
        }
        let box = path.boundingBox
        guard !box.isEmpty else
        {
            self.shapeLayer.frame = self.bounds
            return
        }
        let nativeWidth = box.width
        let nativeHeight = box.height
        let nativeAspectRatio = nativeWidth/nativeHeight;
        let boundedAspectRatio = bounds.width/bounds.height;
        
        var shapeLayerTransform = CGAffineTransform.identity
        var shapeBounds = self.bounds
        switch self.contentsGravity
        {
         
            
        
            case CALayerContentsGravity.bottom:
                shapeBounds = box.offsetBy(dx: bounds.midX-box.midX, dy: bounds.maxY-box.maxY)
            case CALayerContentsGravity.top:
                shapeBounds = box.offsetBy(dx: bounds.midX-box.midX, dy: bounds.minY-box.minY)
            case CALayerContentsGravity.left:
                shapeBounds = box.offsetBy(dx: bounds.minX-box.minX, dy: bounds.midY-box.midY)
            case CALayerContentsGravity.right:
                shapeBounds = box.offsetBy(dx: bounds.maxX-box.maxX, dy: bounds.midY-box.midY)
            case CALayerContentsGravity.bottomLeft:
                shapeBounds = box.offsetBy(dx: bounds.minX-box.minX, dy: bounds.maxY-box.maxY)
            case CALayerContentsGravity.bottomRight:
                shapeBounds = box.offsetBy(dx: bounds.maxX-box.maxX, dy: bounds.maxY-box.maxY)
            case CALayerContentsGravity.topRight:
                shapeLayerTransform = CGAffineTransform(translationX: box.minX, y: box.minY)
                shapeBounds = box.offsetBy(dx: bounds.maxX-box.maxX, dy: bounds.minY-box.minY)
            case CALayerContentsGravity.topLeft:
                shapeBounds = box.offsetBy(dx: bounds.minX-box.minX, dy: bounds.minY-box.minY)
            case CALayerContentsGravity.center:
                
                shapeBounds = box.offsetBy(dx: bounds.midX-box.midX, dy: bounds.midY-box.midY)

            case CALayerContentsGravity.resizeAspectFill:
            
                var scale : CGFloat!
                if(nativeAspectRatio >= boundedAspectRatio)
                {
                    scale = bounds.height / nativeHeight
                }
                else
                {
                    scale = bounds.width / nativeWidth
                }
                
                let scaledBox = CGRect(x: 0.0, y: 0.0, width: nativeWidth*scale, height: nativeHeight*scale)
                shapeLayerTransform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: (bounds.width-scaledBox.width)/2.0, y: (bounds.height-scaledBox.height)/2.0)
            case CALayerContentsGravity.resizeAspect:
                fallthrough
            default:
            var scale : CGFloat!
            if(nativeAspectRatio >= boundedAspectRatio) // blank space on top and bottom
            {
                scale = bounds.width / nativeWidth
            }
            else
            {
                scale = bounds.height / nativeHeight
            }
            let scaledBox = CGRect(x: 0.0, y: 0.0, width: nativeWidth*scale, height: nativeHeight*scale)
            
            shapeBounds = scaledBox.offsetBy(dx: bounds.midX-scaledBox.midX, dy: bounds.midY-scaledBox.midY)
            shapeLayerTransform = CGAffineTransform(scaleX: scale, y: scale)
        }
        shapeLayer.setAffineTransform(shapeLayerTransform)
        self.shapeLayer.frame = shapeBounds
        shapeLayer.setNeedsDisplay()
    }
}
