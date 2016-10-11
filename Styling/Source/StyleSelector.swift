////
////  StyleSelector.swift
////  Scalar2D
////
////  Created by Glenn Howes on 8/27/16.
////  Copyright © 2016 Generally Helpful Software. All rights reserved.
////
//
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
//import Foundation
//
//enum StyleSelector
//{
//    enum RelationShip
//    {
//        case ancestor(StyleSelector)
//        case parent(StyleSelector)
//        case sibling(StyleSelector)
//        case descendent(StyleSelector)
//        case specific(StyleSelector)
//        case all
//        
//    }
//    
//    enum Nth
//    {
//        case odd
//        case even
//        case nth(Int)
//        // case function
//    }
//    
//    enum PseudoClass
//    {
//        case custom(String)
//        case any
//        case not(StyleSelector)
//        case nth_child(Nth)
//        case nth_of_type(Nth)
//        case focus
//        case last_child
//        case active
//        case link
//        case checked
//        case dir
//        case nth_last_of_type
//        case disabled
//        case empty
//        case only_child
//        case enabled
//        case only_of_type
//        case first
//        case optional
//        case first_child
//        case out_of_range
//        case first_of_type
//        case read_only
//        case fullscreen
//        case read_write
//        case required
//        case hover
//        case right
//        case indeterminate
//        case root
//        case in_range
//        case scope
//        case invalid
//        case target
//        csae lang
//        case valid
//        case visited
//        case last_of_type
//        case left
//    }
//    
//    enum AttributePosition
//    {
//        case equals
//        case prefix
//        case suffix
//        case contains
//    }
//    
//    case class(String)
//    case identifier(String)
//    case attribute(attribute:String, value:String?, position:AttributePosition?)
//    indirect case descendent([RelationShip])
//    
//}
//
//enum SyleProperty
//{
//    keyString(String, String)
//    keyNumber(String, Double)
//}
//
//enum Style
//{
//    case fontFace(String, [StyleProperty])
//}
