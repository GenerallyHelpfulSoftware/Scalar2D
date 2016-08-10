//
//  DrawStyle.swift
//  Scalar2D
//
//  Created by Glenn Howes on 7/28/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//

import Foundation
import CoreGraphics

typealias DrawColor = CGColor

typealias DrawDimension = CGFloat

enum ColorStyle
{
    case none
    case current
    case defined(DrawColor)
}

enum StrokeWidth
{
    case none
    case fixed(DrawDimension)
    case absolute(DrawDimension)
}

enum  DrawStyle
{
    case fill(ColorStyle)
    case strokeColor(ColorStyle)
    
}
