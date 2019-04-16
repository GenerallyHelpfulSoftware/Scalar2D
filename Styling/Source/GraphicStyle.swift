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

#if os(iOS) || os(tvOS) || os(OSX)
public typealias NativeDimension = CGFloat
#else
public typealias NativeDimension = Double
#endif

public protocol InheritableProperty
{
    var useInitial : Bool {get}
    var useInherited : Bool {get}
    var useNormal : Bool {get}
}

public  enum StyleUnit
{
    case pixel
    case percent
    case em
    case point
    case centimeter
}

extension String
{
    public var asStyleUnit : StyleUnit?
    {
        switch self.lowercased()
        {
            case "px":
                return .pixel
            case "%":
                return .percent
            case "em":
                return .em
            case "pt":
                return .point
            case "cm":
                return .centimeter
            default:
                return nil
        }
    }
}

public struct UnitDimension : Equatable
{
    public let dimension: NativeDimension
    public let unit : StyleUnit
    public init(dimension: NativeDimension, unit: StyleUnit)
    {
        self.dimension = dimension
        self.unit = unit
    }
}

public  enum StyleProperty
{
    case string(String)
    case unitNumber(UnitDimension)
    case number(Double)
    case colour(Colour, NativeColour?)
    case boolean(Bool)
    
    // half of any graphics library is dealing with drawing text
    case fontStyle(FontStyle)
    case fontVariant(FontVariant)
    case fontFamilies([FontFamily])
    case fontWeight(FontWeight)
    case fontStretch(FontStretch)
    case fontDecorations(Set<TextDecoration>)
    case distance(Distance)
    case fontSize(FontSize)
    
    // stroke properties
    case lineCap(LineCap)
    case lineJoin(LineJoin)
    
    indirect case array([StyleProperty])
    indirect case dimensionArray([UnitDimension])
    
    // remember to update Equatable extension below if you add another case
}

public struct   PropertyKey : RawRepresentable
{
    public let rawValue : String
    
    
    public init?(rawValue: String)
    {
        self.rawValue = rawValue
    }
}

extension PropertyKey : Hashable
{
    
}

public struct GraphicStyle
{
    public let key: PropertyKey
    public let value: StyleProperty
    public let important: Bool
    
    public init(key: PropertyKey, value: StyleProperty, important: Bool = false)
    {
        self.key = key
        self.value = value
        self.important = important
    }
    
    public init(key: PropertyKey, value: String, important: Bool = false)
    {
        self.init(key: key, value: StyleProperty.string(value), important: important)
    }
    /**
         convenient alternate init for creating a graphic style from a constant # style colour description
     **/
    public init(key: PropertyKey, hexColour: String, important: Bool = false)
    {
        let colour = try! HexColourParser().deserializeString(source: hexColour)!
        self.init(key: key, value: StyleProperty.colour(colour, colour.nativeColour), important: important)
    }
    
    /**
     convenient alternate init for creating a graphic style from a constant named web colour description
     **/
    public init(key: PropertyKey, webColour: String, important: Bool = false)
    {
        let colour = try! WebColourParser().deserializeString(source: webColour)!
        self.init(key: key, value: StyleProperty.colour(colour, colour.nativeColour), important: important)
    }
}

/**
    Such a context will be able to resolve an inherited property (for example by looking up the style chain)
**/
public protocol StyleContext
{
    func resolve(property : GraphicStyle) -> StyleProperty?
    func points(fromUnit unit: StyleUnit) -> NativeDimension?
}

public extension StyleContext
{
    // default implementation
    func resolve(property : GraphicStyle) -> StyleProperty?
    {
        return property.value
    }
    
    // default implementation
    func points(value: NativeDimension, fromUnit unit: StyleUnit) -> NativeDimension?
    {
        switch unit
        {
            case .point:
                return value
            default:
                return nil 
        }
    }
}



extension StyleProperty : Equatable
{
    public static func == (lhs: StyleProperty, rhs: StyleProperty) -> Bool {
        switch(lhs, rhs)
        {
            case (.string(let lhsString), .string(let rhsString)):
                return lhsString == rhsString
            case (.unitNumber(let  lhsDimension), .unitNumber(let rhsDimension)):
                return lhsDimension == rhsDimension
            case (.number(let lhsNumber), .number(let rhsNumber)):
                return lhsNumber == rhsNumber
            case (.colour(let lhsColour, let lhsNative), .colour(let rhsColour, let rhsNative)):
                return lhsColour == rhsColour  && lhsNative == rhsNative
            case (.boolean(let lhsBool), .boolean(let rhsBool)):
                return lhsBool == rhsBool
            case (.array(let lhsArray), .array(let rhsArray)):
                return lhsArray == rhsArray
            case (.fontStyle(let lhsStyle), .fontStyle(let rhsStyle)):
                return lhsStyle == rhsStyle
            case (.fontVariant(let lhsVariant), .fontVariant(let rhsVariant)):
                return lhsVariant == rhsVariant
            case (.fontFamilies(let lhsFamilies), .fontFamilies(let rhsFamilies)):
                return lhsFamilies == rhsFamilies
            case (.fontWeight(let lhsWeight), .fontWeight(let rhsWeight)):
                return lhsWeight == rhsWeight
            case (.fontDecorations(let lhsDecorations), .fontDecorations(let rhsDecorations)):
                return lhsDecorations == rhsDecorations
            case (.distance(let lhsHeight), .distance(let rhsHeight)):
                return lhsHeight == rhsHeight
            case (.fontSize(let lhsSize), .fontSize(let rhsSize)):
                return lhsSize == rhsSize
            case (.fontStretch(let lhsStretch), .fontStretch(let rhsStretch)):
                return lhsStretch == rhsStretch
            case (.lineCap(let lhsCap), .lineCap(let rhsCap)):
                return lhsCap == rhsCap
            case (.lineJoin(let lhsJoin), .lineJoin(let rhsJoin)):
                return lhsJoin == rhsJoin
            case (.dimensionArray(let lhsArray), .dimensionArray(let rhsArray)):
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

public extension FontDescription
{
    init(properties : [StyleProperty])
    {
        var fontSize : FontSize? = nil
        var families : [FontFamily]? = nil
        var weight : FontWeight? = nil
        var stretch : FontStretch? = nil
        var decorations : Set<TextDecoration>? = nil
        var style : FontStyle? = nil
        var variant : FontVariant? = nil
        var lineHeight : Distance? = nil
        
        
        for aProperty in properties
        {
            switch aProperty
            {
                case .fontDecorations(let newDecorations):
                    if let oldDecorations = decorations
                    {
                        decorations = oldDecorations.union(newDecorations)
                    }
                    else
                    {
                        decorations = newDecorations
                    }
                case .fontFamilies(let newFamilies):
                    families = newFamilies
                case .fontSize(let newSize):
                    fontSize = newSize
                case .fontStretch(let newStretch):
                    stretch = newStretch
                case .fontStyle(let newStyle):
                    style = newStyle
                case .distance(let newLineHeight):
                    lineHeight = newLineHeight
                case .fontVariant(let newVariant):
                    variant = newVariant
                case .fontWeight(let newWeight):
                    weight = newWeight
                
                default:
                break
            }
        }
        
        self.init(families: families ?? [.inherit],
                  size: fontSize ?? .inherit,
                  weight: weight ?? .inherit,
                  stretch: stretch ?? .inherit,
            decorations: decorations ?? [.inherit],
            style: style ?? .inherit,
            variant: variant ?? .inherit,
            lineHeight: lineHeight ?? .inherit)
    }
}

