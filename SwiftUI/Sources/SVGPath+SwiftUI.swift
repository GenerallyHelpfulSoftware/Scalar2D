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

#if DEBUG
struct TestFrogView_Previews : PreviewProvider {

    
    static var previews: some View {
        GeometryReader
        {
                proxy in
                Path(CGPath.path(fromSVGPath: "M100 250 C167 256 217 249 224 244S234 238 229 218 235 203 249 204 270 157 265 115 C260 100 236 81 228 95 S 221 137 220 145 207 19 135 30 C116 9 86 18 85 43Q66 45 53 68C21 68 17 96 32 112 43 205 113 189 185 212")!.fitting(geometry: proxy)).strokedPath(StrokeStyle(lineWidth:3.0))
        }
    }
}
#endif


#endif
