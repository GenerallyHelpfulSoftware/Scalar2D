//
//  CoreGraphics+Styling.swift
//  Scalar2D
//
//  Created by Glenn Howes on 4/16/19.
//  Copyright © 2019 Generally Helpful Software. All rights reserved.
//
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
import CoreGraphics

public extension LineJoin
{
    var cgLineJoin : CGLineJoin?
    {
        switch self
        {
            case .bevel:
                return .bevel
            case .miter, .miter_clip:
                return .miter
            case .round:
                return .round
            case .normal:
                return .miter
            default:
                return nil
        }
    }
}

public extension LineCap
{
    var cgLineCap : CGLineCap?
    {
        switch self
        {
            case .square:
                return .square
            case .round:
                return .round
            case .butt:
                return .butt
            case .normal:
                return .butt
            default:
                return nil
        }
    }
}
