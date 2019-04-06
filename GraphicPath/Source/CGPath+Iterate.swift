//
//  CGPath+Iterate.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/13/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
//
// based upon tutorial found at http://oleb.net/blog/2015/06/c-callbacks-in-swift/
//
//
// The MIT License (MIT)

//  Copyright (c) 2016 Generally Helpful Software

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
import CoreGraphics

public extension CGPath
{
    /**
        Declaration of the closure type which will be called with the elements of a CGPath.
    **/
    typealias ElementIterator = (_ element: CGPathElement)->Void

    /**
     
        A function that delivers the contents of the CGPath to a provided closure one element at a time. 
        See the apply or CGPathApply function for details.
        - parameters:
            - callback: a closure that takes a CGPathElemnt as the sole parameter.
     **/
    func iterate( _ callback: @escaping ElementIterator)
    {
        var localCallback = callback
        
        withUnsafeMutablePointer(to: &localCallback)
        { callbackPtr in
            self.apply(info: callbackPtr)
            {
                (userInfo, pathElement) in
                let callback = userInfo?.assumingMemoryBound(to: ElementIterator.self).pointee
                callback?(pathElement.pointee)
            }
        }
    }
}
