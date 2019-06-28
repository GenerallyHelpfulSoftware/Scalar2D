//
//  ViewStyle.swift
//  Scalar2D
//
//  Created by Glenn Howes on 4/21/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2016-2017 Generally Helpful Software

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

import Foundation

public struct BorderTypes : OptionSet
{
    public let rawValue: Int
    
    public static let top    = BorderTypes(rawValue: 1 << 0)
    public static let left  = BorderTypes(rawValue: 1 << 1)
    public static let bottom   = BorderTypes(rawValue: 1 << 2)
    public static let right   = BorderTypes(rawValue: 1 << 3)
    
   public  static let horizontal : BorderTypes = [.top, .bottom]
    public static let vertical : BorderTypes = [.left, .right]
    
    public static let whole : BorderTypes = [.left, .right, .top, .bottom]
    
    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
}


struct CornerTypes: OptionSet {
    let rawValue: Int
    
    static let topLeft    = CornerTypes(rawValue: 1 << 0)
    static let topRight  = CornerTypes(rawValue: 1 << 1)
    static let bottomLeft   = CornerTypes(rawValue: 1 << 2)
    static let bottomRight   = CornerTypes(rawValue: 1 << 3)
    
    static let all: CornerTypes = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    static let top: CornerTypes = [.topLeft, .topRight]
    static let bottom: CornerTypes = [.bottomLeft, .bottomRight]
    static let left: CornerTypes = [.bottomLeft, .topLeft]
    static let right: CornerTypes = [.bottomRight, .topRight]
    
}

public struct CornerRadius : Equatable
{
    let corner : CornerTypes
    let xRadius : UnitDimension?
    let yRadius : UnitDimension?
}

public enum BorderStyle : InheritableProperty, Equatable, CaseIterable
{
    case inherit
    case initial
    case normal
    
    case empty
    case hidden
    case dashed
    case dotted
    case solid
    case double
    case groove
    case ridge
    case inset
    case outset
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}

public enum BorderWidth : InheritableProperty, Equatable
{
    case inherit
    case initial
    case normal
    
    case thin
    case medium
    case thick
    
    case custom(UnitDimension)
    
    public var useInitial: Bool
    {
        return  .initial == self
    }
    
    public var useInherited: Bool
    {
        return  .inherit == self
    }
    
    public var useNormal: Bool
    {
        return  .normal == self
    }
}


public struct BorderRecord : Equatable
{
    let types : BorderTypes
    let width : BorderWidth?
    let style : BorderStyle?
    let colour : Colour?
    
    public init(types: BorderTypes, width: BorderWidth?=nil, style: BorderStyle?=nil, colour : Colour? = nil)
    {
        self.types = types
        self.width = width
        self.style = style
        self.colour = colour
    }
}
