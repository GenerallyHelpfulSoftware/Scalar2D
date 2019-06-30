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
@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
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
#endif
