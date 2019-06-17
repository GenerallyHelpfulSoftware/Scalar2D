//
//  ViewStyleInterpreter.swift
//  Scalar2D
//
//  Created by Glenn Howes on 4/28/19.
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

import Foundation

public extension PropertyKey // view
{
    static let background_color = PropertyKey(rawValue: "background-color")!
    static let view_border_style = PropertyKey(rawValue: "border-style")!
    static let view_border_width = PropertyKey(rawValue: "border-width")!
    static let view_border_color = PropertyKey(rawValue: "border-color")!
    static let view_corner_radius = PropertyKey(rawValue: "border-radius")!
}


extension BorderStyle : Nameable
{
    public var cssName: String {
        switch self
        {
        case .inherit:
            return "inherit"
        case .initial:
            return "initial"
        case .normal:
            return "normal"
        case .empty:
            return "none"
        case .hidden:
            return "hidden"
        case .dotted:
            return "dotted"
        case .dashed:
            return "dashed"
        case .solid:
            return "solid"
        case .double:
            return "double"
        case .groove:
            return "groove"
        case .ridge:
            return "ridge"
        case .inset:
            return "inset"
        case .outset:
            return "outset"
        }
    }
}

extension BorderStyle
{
    static func find(inBuffer buffer: String.UnicodeScalarView, inBufferRange bufferRange: Range<String.UnicodeScalarView.Index>) throws -> ([BorderRecord], String.UnicodeScalarView.Index)
    {
        var borderStyles = Array<BorderStyle>()
        var cursor = bufferRange.lowerBound
        try (0...3).forEach
        { _ in // there can be up to 4 border styles. 1 per side of a rectangle.
            if bufferRange.contains(cursor)
            {
                let rangeOfInterest = cursor..<bufferRange.upperBound
                if let (endCursor, style) = try BorderStyle.find(inBuffer: buffer, inBufferRange: rangeOfInterest, usingCases: BorderStyle.allCases)
                {
                    cursor = try buffer.uncommentedIndex(after: endCursor)
                    if let nextEnum = try buffer.findNonWhiteSpace(inRange: cursor..<bufferRange.upperBound)
                    {
                        cursor = nextEnum
                    }
                    
                    borderStyles.append(style as! BorderStyle)
                    
                }
            }
        }
        
        switch borderStyles.count
        {
            case 0:
                throw  StylePropertyFailureReason.incompleteProperty(PropertyKey.view_border_style.rawValue, cursor)
            case 1:
                let wholeRecord = BorderRecord(types: .whole, width: nil, style: borderStyles.first!, colour: nil)
                return ([wholeRecord], cursor)
            case 2:
                let horizontalRecord = BorderRecord(types: .horizontal, width: nil, style: borderStyles.first!, colour: nil)
                let verticalRecord = BorderRecord(types: .vertical, width: nil, style: borderStyles.last!, colour: nil)
                return ([horizontalRecord, verticalRecord], cursor)
            case 3:
                let verticalRecord = BorderRecord(types: .vertical, width: nil, style: borderStyles[1], colour: nil)
                let topRecord = BorderRecord(types: .top, width: nil, style: borderStyles.first!, colour: nil)
                let bottomRecord = BorderRecord(types: .bottom, width: nil, style: borderStyles.last!, colour: nil)
                return ([verticalRecord, topRecord, bottomRecord], cursor)
            case 4:
                let topRecord = BorderRecord(types: .top, width: nil, style: borderStyles.first!, colour: nil)
                let rightRecord = BorderRecord(types: .right, width: nil, style: borderStyles[1], colour: nil)
                let bottomRecord = BorderRecord(types: .bottom, width: nil, style: borderStyles[2], colour: nil)
                let leftRecord = BorderRecord(types: .left, width: nil, style: borderStyles[3], colour: nil)
                return ([topRecord, rightRecord, bottomRecord, leftRecord], cursor)
            default:
                throw  StylePropertyFailureReason.badProperty(PropertyKey.view_border_style.rawValue, cursor)
        }
    }
}

/**
 enumeration of possible border width keys
 */
extension BorderWidth : Nameable
{
    public var cssName : String
    {
        switch self
        {
        case .inherit:
            return "inherit"
        case .initial:
            return "initial"
        case .thin:
            return "thin"
        case .thick:
            return "thick"
        case .medium:
            return "medium"
        case .custom(let value):
            return "\(value)"
        case .normal:
            return "medium"
        }
    }
    
    static var enumerated : [Nameable]
    {
        return [BorderWidth.medium, BorderWidth.thick, BorderWidth.thin, BorderWidth.inherit, BorderWidth.initial]
    }
}

extension BorderWidth
{
    static func find(inBuffer buffer: String.UnicodeScalarView, inBufferRange bufferRange: Range<String.UnicodeScalarView.Index>) throws -> ([BorderRecord], String.UnicodeScalarView.Index)
    {
        var borderWidths = Array<BorderWidth>()
        var cursor = bufferRange.lowerBound
        try (0...3).forEach
        { _ in // there can be up to 4 border widths. 1 per side of a rectangle.
            if bufferRange.contains(cursor)
            {
                let rangeOfInterest = cursor..<bufferRange.upperBound
                if let (endCursor, shouldBeBorderWidth) = try BorderWidth.find(inBuffer: buffer, inBufferRange: rangeOfInterest, usingCases: BorderWidth.enumerated)
                {
                    let width = shouldBeBorderWidth as! BorderWidth
                    cursor = try buffer.uncommentedIndex(after: endCursor)
                    if let nextEnum = try buffer.findNonWhiteSpace(inRange: cursor..<bufferRange.upperBound)
                    {
                        cursor = nextEnum
                    }
                    borderWidths.append(width)
                }
                else  // extract explicit width
                {
                    let character = buffer[cursor]
                    switch character
                    {
                        case "0"..."9", ".":
                        let (possibleValue, possibleUnit, endCursor) = buffer.extractValueAndUnit(fromRange: rangeOfInterest)
                        switch(possibleValue, possibleUnit)
                        {
                            case (nil, nil):
                                throw StylePropertyFailureReason.incompleteProperty(PropertyKey.view_border_width.rawValue, cursor)
                            case (let value, nil):
                                let dimension = UnitDimension(dimension: NativeDimension(value!), unit: .point)
                                let width = BorderWidth.custom(dimension)
                                borderWidths.append(width)
                            case (let value, let unit):
                                guard let styleUnit = unit!.asStyleUnit else
                                {
                                    if let character = unit?.first
                                    {
                                        throw StylePropertyFailureReason.unexpectedCharacter(character, cursor)
                                    }
                                    else
                                    {
                                        throw StylePropertyFailureReason.incompleteProperty(PropertyKey.view_border_width.rawValue, cursor)
                                    }
                                }
                                let dimension = UnitDimension(dimension: NativeDimension(value!), unit: styleUnit)
                                let width = BorderWidth.custom(dimension)
                                borderWidths.append(width)
                            }
                        cursor = try buffer.uncommentedIndex(after: endCursor)
                    default:
                        break
                    }
                }
            }
        }
        
        switch borderWidths.count
        {
            case 0:
                throw  StylePropertyFailureReason.incompleteProperty(PropertyKey.view_border_style.rawValue, cursor)
            case 1:
                let wholeRecord = BorderRecord(types: .whole, width: borderWidths.first!, style: nil, colour: nil)
                return ([wholeRecord], cursor)
            case 2:
                let horizontalRecord = BorderRecord(types: .horizontal, width: borderWidths.first!, style: nil, colour: nil)
                let verticalRecord = BorderRecord(types: .vertical, width: borderWidths.last!, style: nil, colour: nil)
                return ([horizontalRecord, verticalRecord], cursor)
            case 3:
                let verticalRecord = BorderRecord(types: .vertical, width: borderWidths[1], style: nil, colour: nil)
                let topRecord = BorderRecord(types: .top, width: borderWidths.first!, style: nil, colour: nil)
                let bottomRecord = BorderRecord(types: .bottom, width: borderWidths.last!, style: nil, colour: nil)
                return ([verticalRecord, topRecord, bottomRecord], cursor)
            case 4:
                let topRecord = BorderRecord(types: .top, width: borderWidths.first!, style: nil, colour: nil)
                let rightRecord = BorderRecord(types: .right, width: borderWidths[1], style: nil, colour: nil)
                let bottomRecord = BorderRecord(types: .bottom, width: borderWidths[2], style: nil, colour: nil)
                let leftRecord = BorderRecord(types: .left, width: borderWidths[3], style: nil, colour: nil)
                return ([topRecord, rightRecord, bottomRecord, leftRecord], cursor)
            default:
                throw  StylePropertyFailureReason.badProperty(PropertyKey.view_border_style.rawValue, cursor)
        }
    }
}

public class ViewStyleInterpreter : CommonStyleInterpretter
{
    private func findBorderColors(inBuffer buffer: String.UnicodeScalarView, inBufferRange bufferRange: Range<String.UnicodeScalarView.Index>) throws -> ([BorderRecord], String.UnicodeScalarView.Index)
    {
        var colors = Array<Colour>()
        var cursor = bufferRange.lowerBound
        try (0...3).forEach
        {_ in
            if bufferRange.contains(cursor)
            {
                let range = cursor..<bufferRange.upperBound
                if !range.isEmpty
                {
                    let (style, endCursor) = try self.interpretColour(key: .view_border_color, buffer: buffer, bufferRange: range)
                    cursor = try buffer.uncommentedIndex(after: endCursor)
                    switch style.first!.value
                    {
                        case .colour(let colour,  _):
                            colors.append(colour)
                        default:
                            assert(false)
                        
                    }
                }
            }
        }
        switch colors.count
        {
            case 0:
                throw StylePropertyFailureReason.incompleteProperty(PropertyKey.view_border_color.rawValue, cursor)
            case 1:
                return ([BorderRecord(types: .whole, colour: colors.first!)], cursor)
            case 2:
                return (
                    [BorderRecord(types: .horizontal , colour: colors.first!),
                        BorderRecord(types: .vertical , colour: colors.last!)
                
                ], cursor)
            case 3:
                return (
                    [BorderRecord(types: .vertical , colour: colors.first!),
                    BorderRecord(types: .top , colour: colors[1]),
                    BorderRecord(types: .bottom , colour: colors.last!)
                
                ], cursor)
            case 4:
                return (
                [BorderRecord(types: .top , colour: colors[0]),
                BorderRecord(types: .right , colour: colors[1]),
                BorderRecord(types: .bottom , colour: colors[2]),
                BorderRecord(types: .left , colour: colors[3]),
                
                ], cursor)
            default: // can't reach here
                assert(false)
        }
    }
    
    override public func interpret(key: PropertyKey, buffer: String.UnicodeScalarView, inBufferRange bufferRange: Range<String.UnicodeScalarView.Index>) throws -> ([GraphicStyle], String.UnicodeScalarView.Index) {
        
        switch key
        {
           case .background_color:
                return try self.interpretColour(key: key, buffer: buffer, bufferRange: bufferRange)
            case .view_border_style:
                let (borders, cursor)  =  try BorderStyle.find(inBuffer: buffer, inBufferRange: bufferRange)
                let style = GraphicStyle(key: .view_border_style, value: StyleProperty.border(borders))
                return ([style], cursor)
            case .view_border_width:
                let (borders, cursor) = try BorderWidth.find(inBuffer: buffer, inBufferRange: bufferRange)
                let style = GraphicStyle(key: .view_border_width, value: .border(borders))
                return ([style], cursor)
            case .view_border_color:
                let (colours, cursor) = try self.findBorderColors(inBuffer: buffer, inBufferRange: bufferRange)
                let style = GraphicStyle(key: .view_border_color, value: .border(colours))
                return ([style], cursor)
                default:
                return try super.interpret(key: key, buffer: buffer, inBufferRange: bufferRange)
        }
    }
}
