//
//  PathStyle.swift
//  Scalar2D
//
//  Created by Glenn Howes on 1/16/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//
//
// The MIT License (MIT)

//  Copyright (c) 2019 Generally Helpful Software

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

public enum LineCap : InheritableProperty, Equatable, CaseIterable
{
    case inherit
    case initial
    case normal
    
    case butt
    case round
    case square
    
    init?(name : String)
    {
        switch name
        {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "butt":
                self = .butt
            case "round":
                self =  .round
            case "square":
                self = .square
            default:
                return nil
        }
    }
    
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

public enum LineJoin : InheritableProperty, Equatable, CaseIterable
{
    case inherit
    case initial
    case normal
    
    case bevel
    case miter
    case miter_clip
    case round
    
    init?(name : String)
    {
        switch name
        {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "bevel":
                self = .bevel
            case "miter":
                self =  .miter
            case "miter-clip":
                self = .miter_clip
            case "round":
                self = .round
            default:
                return nil
        }
    }
    
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
