//
//  GraphicStyle.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/27/16.
//  Copyright © 2016 Generally Helpful Software. All rights reserved.
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

public  enum StyleUnit
{
    case pixel
    case percent
    case em
    case point
    
}

public  enum StyleProperty
{
    case string(String)
    case unitNumber(Double, StyleUnit)
    case number(Double)
    case colour(Colour)
    case boolean(Bool)
    indirect case array([StyleProperty])
}

public struct GraphicStyle
{
    let key: String
    let value: StyleProperty
    let important: Bool
    
    public init(key: String, value: StyleProperty, important: Bool = false)
    {
        self.key = key
        self.value = value
        self.important = important
    }
    
    public init(key: String, value: String, important: Bool = false)
    {
        self.init(key: key, value: StyleProperty.string(value), important: important)
    }
    /**
         convenient alternate init for creating a graphic style from a constant # style colour description
     **/
    public init(key: String, hexColour: String, important: Bool = false)
    {
        let colour = try! HexColourParser().deserializeString(source: hexColour)!
        self.init(key: key, value: StyleProperty.colour(colour), important: important)
    }
    
    /**
     convenient alternate init for creating a graphic style from a constant named web colour description
     **/
    public init(key: String, webColour: String, important: Bool = false)
    {
        let colour = try! WebColourParser().deserializeString(source: webColour)!
        self.init(key: key, value: StyleProperty.colour(colour), important: important)
    }
}

extension StyleProperty : Equatable
{
    public static func == (lhs: StyleProperty, rhs: StyleProperty) -> Bool {
        switch(lhs, rhs)
        {
            case (.string(let lhsString), .string(let rhsString)):
                return lhsString == rhsString
            case (.unitNumber(let  lhsNumber, let lhsUnit), .unitNumber(let rhsNumber, let rhsUnit)):
                return lhsNumber == rhsNumber && lhsUnit == rhsUnit
            case (.number(let lhsNumber), .number(let rhsNumber)):
                return lhsNumber == rhsNumber
            case (.colour(let lhsColour), .colour(let rhsColour)):
                return lhsColour == rhsColour
            case (.boolean(let lhsBool), .boolean(let rhsBool)):
                return lhsBool == rhsBool
            case (.array(let lhsArray), .array(let rhsArray)):
                return lhsArray == rhsArray
            default:
                return false
        }
    }
}

extension GraphicStyle : Equatable
{
    public static func == (lhs: GraphicStyle, rhs: GraphicStyle) -> Bool {
        return lhs.important == rhs.important && lhs.key == rhs.key && lhs.value == rhs.value
    }
}
