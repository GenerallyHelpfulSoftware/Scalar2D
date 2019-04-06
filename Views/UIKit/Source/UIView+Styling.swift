//
//  UIView+Styling.swift
//  Scalar2D
//
//  Created by Glenn Howes on 10/21/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
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
            objc_setAssociatedObject(self, &STYLEIDENTIFIERKEY, styleIdentifier, .OBJC_ASSOCIATION_RETAIN)
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
