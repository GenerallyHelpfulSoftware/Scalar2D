//
//  File.swift
//  
//
//  Created by Glenn Howes on 7/1/19.
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

#if os(iOS) || os(tvOS) || os(OSX) || os(watchOS)
import Foundation
import CoreGraphics
import SwiftUI
import Scalar2D_GraphicPath

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension Path
{
    /// create a SwiftUI Path element from a svg formatted string
    /// https://www.w3.org/TR/SVG11/paths.html
    /// For example, creating a half circle with a radius of 26:
    /// private let cgPath = CGPath.path(fromSVGPath: "M 0 0 A 25 25 0 1 0 0 50Z")!
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
public extension CGPath
{
    /// Transform this CGPath to fit int the GeometryProxy's size. Will maintain aspect ratio
    /// - Parameter geometry: geometry environment to fit into
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
