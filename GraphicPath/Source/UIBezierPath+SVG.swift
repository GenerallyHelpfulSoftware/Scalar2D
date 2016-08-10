//
//  UIBezierPath+SVG.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/7/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

public extension UIBezierPath
{
    public convenience init?(svgPath: String)
    {
        guard let cgPath = CGPath.pathFromSVGPath(svgPath: svgPath) else
        {
            return nil
        }
        
        self.init(cgPath: cgPath)
    }
}
#endif
