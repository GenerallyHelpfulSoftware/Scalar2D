//
//  FontDescription.swift
//  Scalar2D
//
//  Created by Glenn Howes on 8/26/17.
//  Copyright © 2017 Generally Helpful Software. All rights reserved.
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

import Foundation




public enum FontWeight : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case normal
    case bold
    case bolder
    case lighter
    case custom(Int)
    
    public static func ==(lhs: FontWeight, rhs: FontWeight) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.inherit, .inherit), (.normal, .normal), (.bold, .bold), (.lighter, .lighter):
            return true
        case (.custom(let lhsWeight), .custom(let rhsWeight)):
            return lhsWeight == rhsWeight
        
        default:
            return false
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

public enum FontVariant : InheritableProperty, Equatable
{
    case inherit
    case initial
    
    case normal
    case smallCaps
    
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

public enum FontStyle : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case normal
    case italic
    case oblique
    
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

public enum TextDecoration : InheritableProperty, Equatable
{
    case initial
    case inherit
    case none
    
    case underline
    case overline
    case lineThrough
    
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
        return  .none == self
    }
}

public enum FontStretch : InheritableProperty, Equatable
{
    case normal
    case initial
    case inherit
    
    case ultraCondensed
    case extraCondensed
    case condensed
    case semiCondensed
    case semiExpanded
    case expanded
    case extraExpanded
    case ultraExpanded
    
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

public enum DynamicSize : Equatable
{
    case custom(String)
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption1
    case caption2
    
    public static func ==(lhs: DynamicSize, rhs: DynamicSize) -> Bool {
        switch (lhs, rhs)
        {
            case (.title1, .title1), (.title2, .title2), (.title3, .title3), (.headline,  .headline), (.subheadline, .subheadline), (.body, .body),
                 (.callout, .callout), (.footnote, .footnote), (.caption1, .caption1), (.caption2, .caption2):
                return true
            case (.custom(let lhsValue), .custom(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
        }
    }
}

extension String.UnicodeScalarView
{
    func extractValueAndUnit(fromRange range: Range<String.UnicodeScalarView.Index>) -> (Double?, String?)
    {
        let stringBegin = range.lowerBound
        var cursor = stringBegin
        var hadPeriod = false
        
        while range.contains(cursor)
        {
            let character = self[cursor]
            switch(character)
            {
            case "0"..."9":
                break
            case ".":
                if hadPeriod // two periods
                {
                    return (nil, nil)
                }
                else
                {
                    hadPeriod = true
                }
            default:
                let valueString = String(self[stringBegin..<cursor])
                let unitString = String(self[cursor..<range.upperBound]).lowercased()
                let value = Double(valueString)
                return (value, unitString)
            }
            cursor = self.index(after: cursor)
        }
        let valueString = String(self[range])
        return (Double(valueString), nil)
    }
}

extension String
{
    func extractValueAndUnit() -> (Double?, String?)
    {
        let scalars = self.unicodeScalars
        let stringBegin = scalars.startIndex
        let stringEnd = scalars.endIndex
        return scalars.extractValueAndUnit(fromRange: stringBegin..<stringEnd)
    }
}

public enum FontSize : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    case xxLarge
    
    case larger
    case smaller
    
    case percentage(Double)
    case point(Double)
    case pixel(Double)
    case em(Double)
    case rem(Double)
    case ex(Double)
    case viewPortH(Double)
    case viewPortW(Double)
    case ch(Double)
    
    case dynamic(DynamicSize) // make use of the dynamic type system for accessibiity (not in w3c)
    
    public static func ==(lhs: FontSize, rhs: FontSize) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial), (.inherit, .inherit), (.xxSmall, .xxSmall), (.xSmall, .xSmall), (.small, .small), (.medium, .medium),
             (.large, .large), (.xLarge, .xLarge), (.xxLarge, .xxLarge), (.larger, .larger), (.smaller, .smaller):
            return true
        case (.percentage(let lhsValue), .percentage(let rhsValue)), (.em(let lhsValue), .em(let rhsValue)), (.rem(let lhsValue), .rem(let rhsValue)),  (.ex(let lhsValue), .ex(let rhsValue)), (.viewPortH(let lhsValue), .viewPortH(let rhsValue)), (.ch(let lhsValue), .ch(let rhsValue)), (.point(let lhsValue), .point(let rhsValue)), (.viewPortW(let lhsValue), .viewPortW(let rhsValue)), (.pixel(let lhsValue), .pixel(let rhsValue)):
            return lhsValue == rhsValue
        
        case (.dynamic(let lhsValue), .dynamic(let rhsValue)):
            return lhsValue == rhsValue

        default:
            return false
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
        return  .medium == self
    }
    
    init?(value: Double?, unit: String?)
    {
        if let value = value
        {
            if let unit = unit
            {
                switch unit
                {
                    case "%":
                        self = FontSize.percentage(value)
                    case "px":
                        self = FontSize.pixel(value)
                    case "pt":
                        self = FontSize.point(value)
                    case "em":
                        self = FontSize.em(value)
                    case "rem":
                        self = FontSize.rem(value)
                    case "ex":
                        self = FontSize.ex(value)
                    case "vh":
                        self = FontSize.viewPortH(value)
                    case "vw":
                        self = FontSize.viewPortW(value)
                    case "ch":
                        self = FontSize.ch(value)
                    default:
                    return nil
                }
            }
            else
            {
                self = FontSize.point(value)
            }
        }
        else if let enumeration = unit
        {
            switch enumeration
            {
                case "initial":
                    self = FontSize.initial
                case "inherit":
                    self = FontSize.inherit
                case "medium":
                    self = FontSize.medium
                case "xx-small":
                    self = .xxSmall
                case "x-small":
                    self = .xSmall
                case "small":
                    self = .small
                case "large":
                    self = .large
                case "x-large":
                    self = .xLarge
                case "xx-large":
                    self = .xxLarge
                case "smaller":
                    self = .smaller
                case "larger":
                    self = .larger
                default:
                    return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    init?(string: String)
    {
        let valueAndUnit = string.extractValueAndUnit()
        self.init(value: valueAndUnit.0, unit: valueAndUnit.1)
    }
    
}

public enum LineHeight  : InheritableProperty, Equatable
{
    case initial
    case inherit
    case normal
    
    case multiplier(Double)
    case inUnits(Double, StyleUnit)
    
    public static func ==(lhs: LineHeight, rhs: LineHeight) -> Bool {
        switch (lhs, rhs)
        {
            case (.initial, .initial), (.inherit, .inherit), (.normal, .normal):
                return true
            
            case (.multiplier(let lhsValue), .multiplier(let rhsValue)):
                return lhsValue == rhsValue
            
            case (.inUnits(let lhsValue, let lhsUnits), .inUnits(let rhsValue, let rhsUnits)):
                return lhsValue == rhsValue && lhsUnits == rhsUnits
            default:
                return false
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
    
    init?(value: Double?, unit: String?)
    {
        if let value = value
        {
            if let unit = unit
            {
                switch unit
                {
                case "%":
                    self = LineHeight.inUnits(value, .percent)
                case "px":
                    self = LineHeight.inUnits(value, .pixel)
                case "pt":
                    self = LineHeight.inUnits(value, .point)
                case "cm":
                    self = LineHeight.inUnits(value, .centimeter)
                default:
                    return nil
                }
            }
            else
            {
                self = LineHeight.multiplier(value)
            }
        }
        else if let enumeration = unit
        {
            switch enumeration
            {
                case "initial":
                    self = LineHeight.initial
                case "inherit":
                    self = LineHeight.inherit
                case "normal":
                    self = LineHeight.normal
                default:
                    return nil
            }
        }
        else
        {
            return nil
        }
    }

    init? (string: String)
    {
        let valueAndUnit = string.extractValueAndUnit()
        self.init(value: valueAndUnit.0, unit: valueAndUnit.1)
    }
}

public enum FontFamily : InheritableProperty, Equatable
{
    case initial
    case inherit
    
    case named(String) // extreme preference for valid Postscript name
    case serif
    case sansSerif
    case cursive
    case fantasy
    case monospace
    
    case system // not in W3C standard
    
    public static func ==(lhs: FontFamily, rhs: FontFamily) -> Bool {
        switch (lhs, rhs)
        {
            case (.initial, .initial), (.inherit, .inherit), (.serif, .serif), (.sansSerif, .sansSerif), (.cursive, .cursive),
                 (.fantasy, .fantasy), (.monospace, .monospace):
                return true
            case (.named(let lhsValue), .named(let rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
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
        return  .system == self
    }
    
    public var cssName : String
    {
        switch self
        {
            case .inherit:
                return "inherit"
            case .initial:
                return "initial"
            case .cursive:
                return "cursive"
            case .fantasy:
                return "fantasy"
            case .monospace:
                return "monospace"
            case .sansSerif:
                return "sans-serif"
            case .serif:
                return "serif"
            case .named(_):
                return ""
            case .system:
                return "system"
        }
    }
    
    init?(string: String)
    {
        switch string {
            case "inherit":
                self = .inherit
            case "initial":
                self = .initial
            case "cursive":
                self = .cursive
            case "system":
                self = .system
            case "serif":
                self = .serif
            case "sans-serif":
                self = .sansSerif
            case "monospace":
                self = .monospace
            default:
                if string.isEmpty
                {
                    return nil
                }
                else
                {
                    self = .named(string)
                }
        }
    }
}

public struct FontDescription
{
    let families : [FontFamily]
    let size : FontSize
    let weight : FontWeight
    let stretch : FontStretch
    let decorations : [TextDecoration]
    let style : FontStyle
    let variant : FontVariant
    let lineHeight : LineHeight
    let characterSetLimit : CharacterSet?
    
    public init(
            families: [FontFamily] = [.inherit],
            size : FontSize = .inherit,
            weight : FontWeight = .inherit,
            stretch : FontStretch = .inherit,
            decorations : [TextDecoration] = [.inherit],
            style : FontStyle = .inherit,
            variant : FontVariant = .inherit,
            lineHeight : LineHeight = .inherit,
            characterSetLimit : CharacterSet? = nil
    )
    {
        self.families = families
        self.size = size
        self.weight = weight
        self.stretch = stretch
        self.decorations = decorations
        self.style = style
        self.variant = variant
        self.lineHeight = lineHeight
        self.characterSetLimit = characterSetLimit
    }
    
}
