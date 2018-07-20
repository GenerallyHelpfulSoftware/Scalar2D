//
//  SVGElements.swift
//  Scalar2D
//
// The MIT License (MIT)

//  Copyright (c) 2016-2018 Generally Helpful Software

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
//  Created by Glenn Howes on 3/20/18.
//  Copyright © 2018 Generally Helpful Software. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(OSX)
    public typealias NativePath = CGPath
    public typealias NativeImage = CGImage
    public typealias NativeGradient = CGGradient
    public typealias NativeAffineTransform = CGAffineTransform
    
#else // put whatever is appropriate here
    public typealias NativePath = Any
    public typealias NativeImage = Any
    public typealias NativeGradient = Any
    public typealias NativeAffineTransform = Any
#endif


//protocol SVGElement
//{
//    var identifier : String? {get}
//    var className : String? {get}
//}
//
//protocol SVGContainer : SVGElement
//{
//    var children : [SVGElement]? {get}
//}
//
//struct SVGRoot : SVGContainer
//{
//    public var children: [SVGElement]?
//}
//
//struct SVGDefinitions : SVGContainer
//{
//    public var children: [SVGElement]?
//}
//
//struct SVGGroup : SVGContainer
//{
//
//}
//
//struct SVGImage : SVGElement
//{
//    
//}
