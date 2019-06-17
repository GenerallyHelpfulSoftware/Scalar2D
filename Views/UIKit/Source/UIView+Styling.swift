//
//  UIView+Styling.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/21/17.
//  Copyright © 2017-2019 Generally Helpful Software. All rights reserved.
//
//
//
// The MIT License (MIT)

//  Copyright (c) 2017-2019 Generally Helpful Software

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

import UIKit

extension UIView : StyleableObject, CSSIdentifiable
{
}


fileprivate var STYLEIDENTIFIERKEY: String = "com.genhelp.scalar2D.s"
fileprivate var STYLECLASSIDENTIFIERKEY: String = "com.genhelp.scalar2D.c"

public extension UIView
{
    
    @IBInspectable var styleIdentifier: String?
    {
        set
        {
            objc_setAssociatedObject(self, &STYLEIDENTIFIERKEY, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
        get
        {
            let result =  objc_getAssociatedObject(self, &STYLEIDENTIFIERKEY)
            return result as? String
        }
    }
    
    @IBInspectable var styleClassName: String?
    {
        set
        {
            objc_setAssociatedObject(self, &STYLECLASSIDENTIFIERKEY, styleIdentifier , .OBJC_ASSOCIATION_RETAIN)
        }
        
        get
        {
            let result =  objc_getAssociatedObject(self, &STYLECLASSIDENTIFIERKEY)
            return result as? String
        }
    }
}

extension UIButton
{
    public var styleableElementName : String?
    {
        return "button"
    }
}

extension UILabel
{
    public var styleableElementName : String?
    {
        return "label"
    }
}
