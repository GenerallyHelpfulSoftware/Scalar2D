//
//  File.swift
//  
//
//  Created by Glenn Howes on 7/1/19.
//


#if os(iOS) || os(tvOS) || os(OSX) || os(watchOS)
import Foundation
import CoreGraphics
import SwiftUI
import Scalar2D_GraphicPath
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Path
{
     init?(svgPath: String)
    {
        guard let cgPath = CGPath.path(fromSVGPath: svgPath) else
        {
            return nil
        }
        self.init(cgPath)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension CGPath
{
    func fitting(geometry : GeometryProxy) -> CGPath
    {
        let baseBox = self.boundingBoxOfPath
        guard !baseBox.isEmpty && !baseBox.isInfinite && !baseBox.isNull else
        {
            return self
        }
        
        let nativeWidth = baseBox.width
        let nativeHeight = baseBox.height
        let nativeAspectRatio = nativeWidth/nativeHeight;
        let boundedAspectRatio = geometry.size.width/geometry.size.height;
        
        var scale : CGFloat!
        if(nativeAspectRatio >= boundedAspectRatio) // blank space on top and bottom
        {
            scale = geometry.size.width / nativeWidth
        }
        else
        {
            scale = geometry.size.height / nativeHeight
        }
        var requiredTransform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: -baseBox.minX*scale, y: -baseBox.minY*scale)
        
        return self.copy(using: &requiredTransform) ?? self
    }
}



#endif
